#!/usr/bin/env bash
# =============================================================================
# Aphelix-Labs Engineering Metrics & Code Ownership Report
#
# Automated codebase health and ownership analysis across all org repos.
#
# Metrics:
#   1. git-fame        — surviving LOC by author (git blame attribution)
#   2. Category blame  — ownership by domain (infra, backend, frontend, etc.)
#   3. jscpd           — copy-paste code duplication
#   4. knip            — dead code, unused exports/deps/files
#   5. npm audit       — dependency vulnerabilities
#   6. tsc --noEmit    — TypeScript type safety
#   7. eslint          — coding standards violations
#   8. secrets scan    — hardcoded API keys/credentials in source
#   9. git analysis    — commit counts, fix ratios, author timelines
#  10. GitHub Issues   — issues created/closed per author
#
# Prerequisites:
#   pip install git-fame
#   npm install -g jscpd
#   gh auth login
#
# Usage:
#   bash code-audit.sh
#   bash code-audit.sh --skip-fame     # skip slow git-fame
#   bash code-audit.sh --repos "sutton-dental-care,xcape-velocity"
#   bash code-audit.sh --base-dir /path/to/repos  # for CI
# =============================================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${BASE_DIR:-$(dirname "$SCRIPT_DIR")}"
CACHE_DIR="$SCRIPT_DIR/.contribution-cache"
REPORT_FILE="$SCRIPT_DIR/contribution-report.md"
GITHUB_ORG="Aphelix-Labs"

SKIP_FAME=false
SKIP_QUALITY=false
CUSTOM_REPOS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repos) CUSTOM_REPOS="${2//,/ }"; shift 2 ;;
    --skip-fame) SKIP_FAME=true; shift ;;
    --skip-quality) SKIP_QUALITY=true; shift ;;
    --base-dir) BASE_DIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

mkdir -p "$CACHE_DIR"

# ─── Discover repos ─────────────────────────────────────────────────────────
if [ -n "$CUSTOM_REPOS" ]; then
  REPOS="$CUSTOM_REPOS"
else
  # Dynamically discover all repos in the org directory
  REPOS=""
  for d in "$BASE_DIR"/*/; do
    if [ -d "$d/.git" ]; then
      REPOS="$REPOS $(basename "$d")"
    fi
  done
  REPOS=$(echo "$REPOS" | xargs)  # trim
fi

echo "=============================================="
echo "  Aphelix-Labs Engineering Metrics Report"
echo "  Date: $(date -I)"
echo "  Repos: $REPOS"
echo "=============================================="
echo ""

# ─── Helper: category blame ─────────────────────────────────────────────────
# Runs git blame on files matching given patterns and outputs author line counts
category_blame() {
  local repo_dir="$1"
  shift
  local patterns=("$@")
  local all_files=""

  for pattern in "${patterns[@]}"; do
    local matched
    matched=$(cd "$repo_dir" && git ls-files "$pattern" 2>/dev/null || true)
    if [ -n "$matched" ]; then
      all_files="$all_files
$matched"
    fi
  done

  all_files=$(echo "$all_files" | sed '/^$/d' | sort -u)

  if [ -z "$all_files" ]; then
    return
  fi

  echo "$all_files" | while IFS= read -r f; do
    git -C "$repo_dir" blame --line-porcelain -- "$f" 2>/dev/null || true
  done | grep "^author " | sed 's/^author //' | sort | uniq -c | sort -rn
}

# ─── 1. Git Fame (surviving LOC) ────────────────────────────────────────────
declare -A FAME_SEAN FAME_JUSSY FAME_TOTAL
TOTAL_SEAN=0
TOTAL_JUSSY=0
TOTAL_OTHER=0
TOTAL_LOC=0
COMMITS_SEAN=0
COMMITS_JUSSY=0
FILES_SEAN=0
FILES_JUSSY=0

if [ "$SKIP_FAME" = false ]; then
  echo "[1/10] Running git-fame (surviving LOC by author)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -d "$dir/.git" ]; then
      echo "  $repo..."
      git -C "$dir" fame \
        --excl 'package-lock\.json|bun\.lockb|\.map$|node_modules' \
        --sort loc --format csv \
        > "$CACHE_DIR/${repo}-fame.csv" 2>/dev/null || { echo "  WARN: git-fame failed for $repo"; continue; }

      # Parse CSV (Author,loc,coms,fils,%loc,%coms,%fils)
      # git-fame appends a summary line — skip any line that doesn't start with a name
      while IFS=',' read -r author loc commits files rest; do
        [ "$author" = "Author" ] && continue  # skip header
        # Skip summary/footer lines (non-numeric loc)
        case "$loc" in ''|*[!0-9]*) continue ;; esac
        author_lower=$(echo "$author" | tr '[:upper:]' '[:lower:]')
        case "$author_lower" in
          *sean*|*seanrossharvey*)
            TOTAL_SEAN=$((TOTAL_SEAN + loc))
            COMMITS_SEAN=$((COMMITS_SEAN + commits))
            FILES_SEAN=$((FILES_SEAN + files))
            ;;
          *coffeebubbles*|*justine*|*jussy*)
            TOTAL_JUSSY=$((TOTAL_JUSSY + loc))
            COMMITS_JUSSY=$((COMMITS_JUSSY + commits))
            FILES_JUSSY=$((FILES_JUSSY + files))
            ;;
          *)
            TOTAL_OTHER=$((TOTAL_OTHER + loc))
            ;;
        esac
      done < "$CACHE_DIR/${repo}-fame.csv"
    fi
  done
  TOTAL_LOC=$((TOTAL_SEAN + TOTAL_JUSSY + TOTAL_OTHER))
else
  echo "[1/10] Skipping git-fame (--skip-fame)"
fi
echo ""

# ─── 2. Category Blame ──────────────────────────────────────────────────────
echo "[2/10] Running category-level ownership analysis..."

declare -A CAT_SEAN CAT_JUSSY
CATEGORIES=("Infrastructure" "Backend" "Frontend" "Tests" "Documentation" "Database" "Data_Config")

for cat in "${CATEGORIES[@]}"; do
  CAT_SEAN[$cat]=0
  CAT_JUSSY[$cat]=0
done

for repo in $REPOS; do
  dir="$BASE_DIR/$repo"
  [ -d "$dir/.git" ] || continue
  echo "  $repo..."

  # Infrastructure & DevOps
  result=$(category_blame "$dir" "*.yml" "*.yaml" "*.toml" "Dockerfile" "docker-compose*" ".github/*" ".github/**/*" "netlify.toml" "vercel.json" "wrangler.toml" ".eslintrc*" "eslint.config*" "vite.config*" "tsconfig*" ".gitignore" ".prettierrc*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Infrastructure]=$((${CAT_SEAN[Infrastructure]} + sean_lines))
    CAT_JUSSY[Infrastructure]=$((${CAT_JUSSY[Infrastructure]} + jussy_lines))
  fi

  # Backend & API
  result=$(category_blame "$dir" "netlify/functions/*" "netlify/functions/**/*" "supabase/functions/*" "supabase/functions/**/*" "src/lib/*" "src/api/*" "src/services/*" "src/integrations/*" "src/integrations/**/*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Backend]=$((${CAT_SEAN[Backend]} + sean_lines))
    CAT_JUSSY[Backend]=$((${CAT_JUSSY[Backend]} + jussy_lines))
  fi

  # Frontend & UI
  result=$(category_blame "$dir" "src/components/*" "src/components/**/*" "src/pages/*" "src/pages/**/*" "src/layouts/*" "*.css" "*.scss" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Frontend]=$((${CAT_SEAN[Frontend]} + sean_lines))
    CAT_JUSSY[Frontend]=$((${CAT_JUSSY[Frontend]} + jussy_lines))
  fi

  # Tests
  result=$(category_blame "$dir" "src/test/*" "src/test/**/*" "tests/*" "tests/**/*" "*.test.*" "*.spec.*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Tests]=$((${CAT_SEAN[Tests]} + sean_lines))
    CAT_JUSSY[Tests]=$((${CAT_JUSSY[Tests]} + jussy_lines))
  fi

  # Documentation
  result=$(category_blame "$dir" "docs/*" "docs/**/*" "*.md" "README*" "CHANGELOG*" "LICENSE*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Documentation]=$((${CAT_SEAN[Documentation]} + sean_lines))
    CAT_JUSSY[Documentation]=$((${CAT_JUSSY[Documentation]} + jussy_lines))
  fi

  # Database & Schema
  result=$(category_blame "$dir" "supabase/migrations/*" "supabase/migrations/**/*" "*.sql" "src/types/*database*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Database]=$((${CAT_SEAN[Database]} + sean_lines))
    CAT_JUSSY[Database]=$((${CAT_JUSSY[Database]} + jussy_lines))
  fi

  # Data & Config (types, constants, data files)
  result=$(category_blame "$dir" "src/data/*" "src/config/*" "src/constants/*" "src/types/*" "src/stores/*" 2>/dev/null || true)
  if [ -n "$result" ]; then
    sean_lines=$(echo "$result" | { grep -i -E "sean|seanrossharvey" || true; } | awk '{s+=$1}END{print s+0}')
    jussy_lines=$(echo "$result" | { grep -i -E "coffeebubbles|justine|jussy" || true; } | awk '{s+=$1}END{print s+0}')
    CAT_SEAN[Data_Config]=$((${CAT_SEAN[Data_Config]} + sean_lines))
    CAT_JUSSY[Data_Config]=$((${CAT_JUSSY[Data_Config]} + jussy_lines))
  fi
done
echo ""

# ─── 3-7. Code Quality Metrics ──────────────────────────────────────────────
if [ "$SKIP_QUALITY" = false ]; then

  # 3. Code Duplication (jscpd)
  echo "[3/10] Running jscpd (code duplication)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -d "$dir/src" ]; then
      echo "  $repo..."
      cd "$dir" && jscpd src --reporters consoleFull --format "typescript,typescriptreact" \
        --min-lines 10 --min-tokens 50 --silent \
        > "$CACHE_DIR/${repo}-jscpd.txt" 2>&1 || true
    fi
  done
  echo ""

  # 4. Dead Code (knip)
  echo "[4/10] Running knip (dead code / unused exports)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -f "$dir/package.json" ]; then
      echo "  $repo..."
      cd "$dir" && npx knip --no-exit-code --reporter compact \
        > "$CACHE_DIR/${repo}-knip.txt" 2>&1 || true
    fi
  done
  echo ""

  # 5. Dependency Vulnerabilities (npm audit)
  echo "[5/10] Running npm audit (dependency vulnerabilities)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -f "$dir/package.json" ]; then
      cd "$dir" && npm audit --json > "$CACHE_DIR/${repo}-audit.json" 2>/dev/null || true
    fi
  done
  echo ""

  # 6. TypeScript Compilation
  echo "[6/10] Running tsc --noEmit (type safety)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -f "$dir/tsconfig.json" ]; then
      errors=$(cd "$dir" && npx tsc --noEmit 2>&1 | grep -c "error TS" || true)
      echo "  $repo: $errors errors"
    fi
  done
  echo ""

  # 7. ESLint
  echo "[7/10] Running eslint (coding standards)..."
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -f "$dir/eslint.config.js" ] || [ -f "$dir/.eslintrc.json" ]; then
      count=$(cd "$dir" && npx eslint src/ --format compact 2>/dev/null | wc -l || true)
      echo "  $repo: $count findings"
    fi
  done
  echo ""

else
  echo "[3-7/10] Skipping quality metrics (--skip-quality)"
  echo ""
fi

# ─── 8. Secrets Scan ────────────────────────────────────────────────────────
echo "[8/10] Running detect-secrets (automated secrets scanner)..."
for repo in $REPOS; do
  dir="$BASE_DIR/$repo"
  if [ -d "$dir" ]; then
    cd "$dir" && detect-secrets scan \
      --exclude-files "node_modules|dist|\.lock|\.map" \
      > "$CACHE_DIR/${repo}-secrets.json" 2>/dev/null || true
  fi
done
echo ""

# ─── 9. Git Commit Analysis ─────────────────────────────────────────────────
echo "[9/10] Git commit analysis (counts + fix ratios)..."
SEAN_FIXES=0
JUSSY_FIXES=0
for repo in $REPOS; do
  dir="$BASE_DIR/$repo"
  if [ -d "$dir/.git" ]; then
    # Fix commits per author
    sean_fix=$(git -C "$dir" log --all --oneline --author="Sean\|SeanRossHarvey" --grep="fix\|refactor\|correct\|rewrite" -i 2>/dev/null | wc -l || echo 0)
    jussy_fix=$(git -C "$dir" log --all --oneline --author="coffeebubbles\|CoffeeBubbles\|Justine" --grep="fix\|refactor\|correct\|rewrite" -i 2>/dev/null | wc -l || echo 0)
    SEAN_FIXES=$((SEAN_FIXES + sean_fix))
    JUSSY_FIXES=$((JUSSY_FIXES + jussy_fix))
  fi
done
echo "  Sean fix/refactor commits: $SEAN_FIXES"
echo "  Jussy fix/refactor commits: $JUSSY_FIXES"
echo ""

# ─── 10. GitHub Issues ──────────────────────────────────────────────────────
echo "[10/10] GitHub Issues (closed, by author)..."
SEAN_ISSUES=0
JUSSY_ISSUES=0
for repo in $REPOS; do
  tmpf="$CACHE_DIR/${repo}-issues.json"
  gh issue list --repo "$GITHUB_ORG/$repo" --state closed --limit 500 --json number,author > "$tmpf" 2>/dev/null || echo "[]" > "$tmpf"
  sean_count=$(node -e "try{const d=JSON.parse(require('fs').readFileSync('$tmpf','utf8'));console.log(d.filter(i=>i.author&&i.author.login==='SeanRossHarvey').length)}catch{console.log(0)}" 2>/dev/null || echo 0)
  jussy_count=$(node -e "try{const d=JSON.parse(require('fs').readFileSync('$tmpf','utf8'));console.log(d.filter(i=>i.author&&i.author.login==='coffeebubbles').length)}catch{console.log(0)}" 2>/dev/null || echo 0)
  SEAN_ISSUES=$((SEAN_ISSUES + sean_count))
  JUSSY_ISSUES=$((JUSSY_ISSUES + jussy_count))
done
echo "  Sean issues closed: $SEAN_ISSUES"
echo "  Jussy issues closed: $JUSSY_ISSUES"
echo ""

# ─── Generate Report ────────────────────────────────────────────────────────
echo "Generating report..."

HUMAN_LOC=$((TOTAL_SEAN + TOTAL_JUSSY))
if [ "$HUMAN_LOC" -gt 0 ]; then
  SEAN_PCT=$((TOTAL_SEAN * 1000 / HUMAN_LOC))
  JUSSY_PCT=$((TOTAL_JUSSY * 1000 / HUMAN_LOC))
  SEAN_PCT_FMT="$((SEAN_PCT / 10)).$((SEAN_PCT % 10))"
  JUSSY_PCT_FMT="$((JUSSY_PCT / 10)).$((JUSSY_PCT % 10))"
else
  SEAN_PCT_FMT="0.0"
  JUSSY_PCT_FMT="0.0"
fi

if [ "$COMMITS_SEAN" -gt 0 ]; then
  LOC_PER_COMMIT_SEAN=$((TOTAL_SEAN / COMMITS_SEAN))
else
  LOC_PER_COMMIT_SEAN=0
fi
if [ "$COMMITS_JUSSY" -gt 0 ]; then
  LOC_PER_COMMIT_JUSSY=$((TOTAL_JUSSY / COMMITS_JUSSY))
else
  LOC_PER_COMMIT_JUSSY=0
fi

SEAN_FIX_TOTAL=$((SEAN_FIXES + JUSSY_FIXES))
if [ "$COMMITS_SEAN" -gt 0 ]; then
  SEAN_FIX_PCT=$((SEAN_FIXES * 1000 / COMMITS_SEAN))
  SEAN_FIX_FMT="$((SEAN_FIX_PCT / 10)).$((SEAN_FIX_PCT % 10))"
else
  SEAN_FIX_FMT="0.0"
fi
if [ "$COMMITS_JUSSY" -gt 0 ]; then
  JUSSY_FIX_PCT=$((JUSSY_FIXES * 1000 / COMMITS_JUSSY))
  JUSSY_FIX_FMT="$((JUSSY_FIX_PCT / 10)).$((JUSSY_FIX_PCT % 10))"
else
  JUSSY_FIX_FMT="0.0"
fi

# Count repos per author
SEAN_REPOS=0
JUSSY_REPOS=0
for repo in $REPOS; do
  dir="$BASE_DIR/$repo"
  [ -d "$dir/.git" ] || continue
  sean_has=$(git -C "$dir" log --all --oneline --author="Sean\|SeanRossHarvey" -1 2>/dev/null | wc -l || echo 0)
  jussy_has=$(git -C "$dir" log --all --oneline --author="coffeebubbles\|CoffeeBubbles\|Justine" -1 2>/dev/null | wc -l || echo 0)
  [ "$sean_has" -gt 0 ] && SEAN_REPOS=$((SEAN_REPOS + 1))
  [ "$jussy_has" -gt 0 ] && JUSSY_REPOS=$((JUSSY_REPOS + 1))
done

REPO_COUNT=$(echo "$REPOS" | wc -w | xargs)

cat > "$REPORT_FILE" << REPORT_EOF
# Aphelix-Labs Engineering Metrics & Code Ownership Report

**Generated:** $(date -I)
**Pipeline:** \`bash scripts/code-audit.sh\`
**Tools:** git-fame, jscpd, knip, npm audit, tsc, eslint, detect-secrets, git log, gh CLI
**Repos analysed:** $REPO_COUNT

---

## Methodology

This report uses **git blame attribution** as the primary metric. \`git blame\` traces every line of code currently in the codebase back to the commit (and author) that last modified it. This measures **surviving code** — code that exists in production right now. Deleted, overwritten, or refactored code is attributed to the person who wrote the current version, not the original.

This is the industry-standard metric used by [git-fame](https://github.com/casperdcl/git-fame), the leading open-source contribution analysis tool. It is more meaningful than commit counts or lines added, because it measures **what remains** rather than what was attempted.

---

## 1. Org-wide Code Ownership (Surviving LOC)

| | Sean | Jussy | Other/Bots |
|---|---|---|---|
| **Surviving LOC** | **$TOTAL_SEAN** | **$TOTAL_JUSSY** | $TOTAL_OTHER |
| **% of human code** | **${SEAN_PCT_FMT}%** | **${JUSSY_PCT_FMT}%** | — |
| **Commits** | $COMMITS_SEAN | $COMMITS_JUSSY | — |
| **LOC per commit** | **$LOC_PER_COMMIT_SEAN** | $LOC_PER_COMMIT_JUSSY | — |
| **Files touched** | $FILES_SEAN | $FILES_JUSSY | — |
| **Repos contributed to** | $SEAN_REPOS / $REPO_COUNT | $JUSSY_REPOS / $REPO_COUNT | — |

---

## 2. Code Ownership by Domain

Surviving lines attributed by file category across all repos.

| Domain | Sean LOC | Jussy LOC | Sean % | Jussy % |
|---|---|---|---|---|
REPORT_EOF

# Write category rows
for cat in "${CATEGORIES[@]}"; do
  s=${CAT_SEAN[$cat]}
  j=${CAT_JUSSY[$cat]}
  total=$((s + j))
  if [ "$total" -gt 0 ]; then
    s_pct=$((s * 1000 / total))
    j_pct=$((j * 1000 / total))
    s_fmt="$((s_pct / 10)).$((s_pct % 10))"
    j_fmt="$((j_pct / 10)).$((j_pct % 10))"
  else
    s_fmt="0.0"
    j_fmt="0.0"
  fi
  cat_label="${cat//_/ }"
  echo "| **$cat_label** | $s | $j | ${s_fmt}% | ${j_fmt}% |" >> "$REPORT_FILE"
done

# Calculate uncategorised (total from git-fame minus sum of categories)
CAT_SEAN_TOTAL=0
CAT_JUSSY_TOTAL=0
for cat in "${CATEGORIES[@]}"; do
  CAT_SEAN_TOTAL=$((CAT_SEAN_TOTAL + ${CAT_SEAN[$cat]}))
  CAT_JUSSY_TOTAL=$((CAT_JUSSY_TOTAL + ${CAT_JUSSY[$cat]}))
done
UNCAT_SEAN=$((TOTAL_SEAN - CAT_SEAN_TOTAL))
UNCAT_JUSSY=$((TOTAL_JUSSY - CAT_JUSSY_TOTAL))
# Clamp to zero (categories can sometimes double-count overlapping patterns)
[ "$UNCAT_SEAN" -lt 0 ] && UNCAT_SEAN=0
[ "$UNCAT_JUSSY" -lt 0 ] && UNCAT_JUSSY=0
UNCAT_TOTAL=$((UNCAT_SEAN + UNCAT_JUSSY))
if [ "$UNCAT_TOTAL" -gt 0 ]; then
  u_s_pct=$((UNCAT_SEAN * 1000 / UNCAT_TOTAL))
  u_j_pct=$((UNCAT_JUSSY * 1000 / UNCAT_TOTAL))
  echo "| **Other** | $UNCAT_SEAN | $UNCAT_JUSSY | $((u_s_pct/10)).$((u_s_pct%10))% | $((u_j_pct/10)).$((u_j_pct%10))% |" >> "$REPORT_FILE"
fi
# Totals row
ALL_CAT_SEAN=$((CAT_SEAN_TOTAL + UNCAT_SEAN))
ALL_CAT_JUSSY=$((CAT_JUSSY_TOTAL + UNCAT_JUSSY))
ALL_CAT_TOTAL=$((ALL_CAT_SEAN + ALL_CAT_JUSSY))
if [ "$ALL_CAT_TOTAL" -gt 0 ]; then
  t_s_pct=$((ALL_CAT_SEAN * 1000 / ALL_CAT_TOTAL))
  t_j_pct=$((ALL_CAT_JUSSY * 1000 / ALL_CAT_TOTAL))
  echo "| **TOTAL** | **$ALL_CAT_SEAN** | **$ALL_CAT_JUSSY** | **$((t_s_pct/10)).$((t_s_pct%10))%** | **$((t_j_pct/10)).$((t_j_pct%10))%** |" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << REPORT_EOF2

---

## 3. Per-repo Code Ownership

REPORT_EOF2

# Per-repo table
echo "| Repo | Total LOC | Sean LOC (%) | Jussy LOC (%) | Other (%) |" >> "$REPORT_FILE"
echo "|------|-----------|-------------|--------------|-----------|" >> "$REPORT_FILE"
for repo in $REPOS; do
  if [ -f "$CACHE_DIR/${repo}-fame.csv" ]; then
    repo_sean=0; repo_jussy=0; repo_other=0; repo_total=0
    while IFS=',' read -r author loc commits files rest; do
      [ "$author" = "Author" ] && continue
      case "$loc" in ''|*[!0-9]*) continue ;; esac
      author_lower=$(echo "$author" | tr '[:upper:]' '[:lower:]')
      case "$author_lower" in
        *sean*|*seanrossharvey*) repo_sean=$((repo_sean + loc)) ;;
        *coffeebubbles*|*justine*|*jussy*) repo_jussy=$((repo_jussy + loc)) ;;
        *) repo_other=$((repo_other + loc)) ;;
      esac
      repo_total=$((repo_total + loc))
    done < "$CACHE_DIR/${repo}-fame.csv"
    if [ "$repo_total" -gt 0 ]; then
      sp=$((repo_sean * 1000 / repo_total)); sp_f="$((sp/10)).$((sp%10))"
      jp=$((repo_jussy * 1000 / repo_total)); jp_f="$((jp/10)).$((jp%10))"
      op=$((repo_other * 1000 / repo_total)); op_f="$((op/10)).$((op%10))"
      echo "| $repo | $repo_total | $repo_sean (${sp_f}%) | $repo_jussy (${jp_f}%) | $repo_other (${op_f}%) |" >> "$REPORT_FILE"
    fi
  fi
done

cat >> "$REPORT_FILE" << REPORT_EOF3

---

## 4. Engineering Quality

### Fix & Maintenance Commits

| | Sean | Jussy |
|---|---|---|
| **Fix/refactor commits** | $SEAN_FIXES | $JUSSY_FIXES |
| **Fix ratio (fix commits / total)** | ${SEAN_FIX_FMT}% | ${JUSSY_FIX_FMT}% |

### GitHub Issues Closed (Aphelix-Labs org)

| | Sean | Jussy |
|---|---|---|
| **Issues closed** | $SEAN_ISSUES | $JUSSY_ISSUES |

REPORT_EOF3

# Add quality details if not skipped
if [ "$SKIP_QUALITY" = false ]; then
  echo "### Code Duplication (jscpd)" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "| Repo | Duplication % |" >> "$REPORT_FILE"
  echo "|------|---------------|" >> "$REPORT_FILE"
  for repo in $REPOS; do
    if [ -f "$CACHE_DIR/${repo}-jscpd.txt" ]; then
      dup_pct=$(grep -oP '\d+\.\d+%' "$CACHE_DIR/${repo}-jscpd.txt" | tail -1 || echo "0%")
      echo "| $repo | $dup_pct |" >> "$REPORT_FILE"
    fi
  done
  echo "" >> "$REPORT_FILE"

  echo "### TypeScript Compilation" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "| Repo | Errors |" >> "$REPORT_FILE"
  echo "|------|--------|" >> "$REPORT_FILE"
  for repo in $REPOS; do
    dir="$BASE_DIR/$repo"
    if [ -f "$dir/tsconfig.json" ]; then
      errors=$(cd "$dir" && npx tsc --noEmit 2>&1 | grep -c "error TS" || true)
      echo "| $repo | $errors |" >> "$REPORT_FILE"
    fi
  done
  echo "" >> "$REPORT_FILE"

  echo "### Dependency Vulnerabilities" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "| Repo | Critical | High | Moderate | Low |" >> "$REPORT_FILE"
  echo "|------|----------|------|----------|-----|" >> "$REPORT_FILE"
  for repo in $REPOS; do
    if [ -f "$CACHE_DIR/${repo}-audit.json" ]; then
      result=$(node -e "try{const d=JSON.parse(require('fs').readFileSync('$CACHE_DIR/${repo}-audit.json','utf8'));const v=d.metadata.vulnerabilities;console.log(v.critical+'|'+v.high+'|'+v.moderate+'|'+v.low)}catch{console.log('0|0|0|0')}" 2>/dev/null || echo "0|0|0|0")
      IFS='|' read -r c h m l <<< "$result"
      echo "| $repo | $c | $h | $m | $l |" >> "$REPORT_FILE"
    fi
  done
  echo "" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << REPORT_EOF4

---

## 5. Domain Category Definitions

| Domain | File patterns | What it covers |
|---|---|---|
| **Infrastructure** | \`*.yml\`, \`*.toml\`, \`Dockerfile\`, \`.github/**\`, \`netlify.toml\`, \`vite.config*\`, \`tsconfig*\` | CI/CD, deployment, build configs |
| **Backend** | \`netlify/functions/**\`, \`supabase/functions/**\`, \`src/lib/**\`, \`src/services/**\`, \`src/integrations/**\` | Server functions, API endpoints, integrations |
| **Frontend** | \`src/components/**\`, \`src/pages/**\`, \`*.css\`, \`*.scss\` | React components, pages, styling |
| **Tests** | \`src/test/**\`, \`tests/**\`, \`*.test.*\`, \`*.spec.*\` | Unit, integration, E2E tests |
| **Documentation** | \`docs/**\`, \`*.md\`, \`README*\` | Technical docs, runbooks |
| **Database** | \`supabase/migrations/**\`, \`*.sql\`, \`*database.types*\` | Migrations, schema, DB types |
| **Data & Config** | \`src/data/**\`, \`src/types/**\`, \`src/stores/**\`, \`src/constants/**\` | Type definitions, data, state stores |

> **Note:** Business development, client outreach, and design decisions are valuable contributions not captured by git metrics. This report measures code ownership only.

---

*Generated by \`scripts/code-audit.sh\` — rerun anytime for updated numbers.*
*Uses [git-fame](https://github.com/casperdcl/git-fame) v3.1.1 for git blame attribution.*
REPORT_EOF4

echo ""
echo "=============================================="
echo "  Report complete!"
echo "  Cache:  $CACHE_DIR/"
echo "  Report: $REPORT_FILE"
echo "=============================================="
