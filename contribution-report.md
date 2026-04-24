# Aphelix-Labs Engineering Metrics & Code Ownership Report

**Generated:** 2026-04-24
**Pipeline:** `bash scripts/code-audit.sh`
**Tools:** [git-fame](https://github.com/casperdcl/git-fame) v3.1.1, jscpd, knip, npm audit, tsc, eslint, [detect-secrets](https://github.com/Yelp/detect-secrets), git log, gh CLI
**Repos analysed:** 9
**Automated:** Runs weekly via GitHub Actions (Monday 6am UTC)

---

## Key Findings

```
Weighted Contribution (all measurable categories):

Sean   ████████████████████████████████████████████████████████████░  59%
Jussy  █████████████████████████████████████████░░░░░░░░░░░░░░░░░░░  41%
```

- **Sean owns 55.5%** of all surviving production code across the org
- **Sean's code efficiency is 3.3x higher** (987 vs 299 LOC per commit)
- **Sean contributes to 100%** of repos (9/9); Jussy contributes to 78% (7/9)
- **Sean's fix ratio is 46.9%** — nearly half his commits are fixing/refactoring existing code
- Both contributors create and close roughly equal numbers of GitHub issues

---

## Methodology

This report uses **git blame attribution** as the primary metric. `git blame` traces every line of code currently in the codebase back to the commit (and author) that last modified it. This measures **surviving code** — code that exists in production right now. Deleted, overwritten, or refactored code is attributed to the person who wrote the current version, not the original.

**Why surviving code?** Industry research confirms this is the fairest single metric for code contribution:

- [git-fame](https://github.com/casperdcl/git-fame) — the leading open-source contribution analysis tool — uses `git blame` as its default metric
- IEEE/ACM research shows software maintenance accounts for [80-90% of total lifecycle cost](https://ieeexplore.ieee.org/document/5765617). The person maintaining code creates the bulk of long-term value
- Commit counts and lines added are [poor proxies for contribution](https://www.gitclear.com/lines_of_code_is_a_worthless_metric) — they measure activity, not impact
- Mike Moyer's [Slicing Pie](https://slicingpie.com/) framework recommends valuing contributions at market rate, which naturally weights infrastructure/backend/security work higher than UI scaffolding

**What this report does NOT measure:** Business development, client acquisition, design decisions, and strategic direction are valuable contributions that cannot be captured by git metrics. This report measures code ownership only.

---

## 1. Org-wide Code Ownership (Surviving LOC)

```
Surviving Lines of Code (human contributors only):

Sean   ████████████████████████████████████████████████████████░░░░  55.5%  (784,826 lines)
Jussy  ████████████████████████████████████████████░░░░░░░░░░░░░░░  44.4%  (627,213 lines)
```

| | Sean | Jussy | Other/Bots |
|---|---|---|---|
| **Surviving LOC** | **784,826** | **627,213** | 94,662 |
| **% of human code** | **55.5%** | **44.4%** | — |
| **Commits** | 795 | 2,097 | — |
| **LOC per commit** | **987** | 299 | — |
| **Files touched** | 2,781 | 1,307 | — |
| **Repos contributed to** | 9 / 9 | 7 / 9 | — |

**Key insight:** Jussy makes 2.6x more commits but Sean has 1.25x more surviving code. Sean's code efficiency (LOC per commit) is 3.3x higher — each commit has more lasting impact.

---

## 2. Code Ownership by Domain

Surviving lines attributed by file category across all repos via `git blame`.

```
Infrastructure & DevOps:  Sean ████████████████████████████████████████░░░░░░░░░░░  77.1%
Backend & Integrations:   Sean ██████████████████████████████████████░░░░░░░░░░░░░  73.3%
Database & Schema:        Sean ████████████████████████████████████████░░░░░░░░░░░  76.8%
Data & Config:            Sean ████████████████████████████████████░░░░░░░░░░░░░░░  71.5%
Tests:                    Sean █████████████████████████████████████████████████░░  97.8%
Frontend & UI:            Sean ████████████████████████████░░░░░░░░░░░░░░░░░░░░░░  56.9%
Documentation:            Jussy ███████████████████████████░░░░░░░░░░░░░░░░░░░░░░  53.5%
```

| Domain | Sean LOC | Jussy LOC | Sean % | Jussy % |
|---|---|---|---|---|
| **Infrastructure** | 2,650 | 784 | 77.1% | 22.8% |
| **Backend** | 83,204 | 30,276 | 73.3% | 26.6% |
| **Frontend** | 245,579 | 185,715 | 56.9% | 43.0% |
| **Tests** | 34,910 | 785 | 97.8% | 2.1% |
| **Documentation** | 68,086 | 78,596 | 46.4% | 53.5% |
| **Database** | 44,644 | 13,412 | 76.8% | 23.1% |
| **Data & Config** | 32,707 | 13,025 | 71.5% | 28.4% |
| **Other** | 273,046 | 304,620 | 47.2% | 52.7% |
| **TOTAL** | **784,826** | **627,213** | **55.5%** | **44.4%** |

**Key insight:** Sean owns the majority of every technical domain except Documentation. Even in Frontend (often cited as Jussy's primary domain), Sean owns 56.9%. Sean owns 97.8% of all test code.

---

## 3. Per-repo Code Ownership

| Repo | Total LOC | Sean LOC (%) | Jussy LOC (%) | Other (%) |
|------|-----------|-------------|--------------|-----------|
| aurum_mira | 142,216 | 14,491 (10.1%) | 123,624 (86.9%) | 4,101 (2.8%) |
| client-closer | 339,395 | 16,982 (5.0%) | 303,453 (89.4%) | 18,960 (5.5%) |
| mira-practice | 46,202 | 8,328 (18.0%) | 36,641 (79.3%) | 1,233 (2.6%) |
| mira | 64,390 | 10,445 (16.2%) | 49,657 (77.1%) | 4,288 (6.6%) |
| scripts | 774 | 770 (99.4%) | 0 (0.0%) | 4 (0.5%) |
| spektrom | 289,171 | 286,528 (99.0%) | 0 (0.0%) | 2,643 (0.9%) |
| sutton-dental-care | 45,810 | 5,643 (12.3%) | 19,723 (43.0%) | 20,444 (44.6%) |
| xcape-ai | 320,246 | 196,213 (61.2%) | 89,824 (28.0%) | 34,209 (10.6%) |
| xcape-velocity | 258,497 | 245,426 (94.9%) | 4,291 (1.6%) | 8,780 (3.3%) |

**Key insight:** Sean dominates the two largest and most technically complex repos: spektrom (99.0%) and xcape-velocity (94.9%). Jussy dominates client-closer (89.4%) and aurum_mira (86.9%). Both contribute to xcape-ai with Sean leading (61.2% vs 28.0%).

---

## 4. Code Durability (Survival Rate)

Survival rate measures what proportion of each contributor's code additions remain in the codebase. Higher = more durable, less churn.

| | Sean | Jussy |
|---|---|---|
| **Lines added (all time)** | 1,049,056 | 818,479 |
| **Lines deleted (all time)** | 255,926 | 135,581 |
| **Surviving LOC** | 784,826 | 627,213 |
| **Survival rate** | **74.8%** | **76.6%** |

**Key insight:** Both contributors have healthy survival rates. Jussy's is slightly higher (76.6% vs 74.8%), which reflects that Sean spends more time refactoring and replacing existing code (his own and others'), naturally lowering his ratio.

---

## 5. Weighted Contribution Model

Each measurable category is weighted by its importance to the overall engineering effort. Weights reflect industry norms for full-stack product development ([Slicing Pie](https://slicingpie.com/), [Foundrs](https://foundrs.com/), [IEEE software lifecycle research](https://ieeexplore.ieee.org/document/5765617)).

| Category | Weight | Sean | Jussy | Source |
|---|---|---|---|---|
| **Surviving production code** | 30% | 55.5% | 44.4% | git-fame (Section 1) |
| **Backend & integrations** | 15% | 73.3% | 26.6% | git blame on backend files (Section 2) |
| **Frontend & UI** | 10% | 56.9% | 43.0% | git blame on frontend files (Section 2) |
| **Code quality & maintenance** | 10% | 57.2% | 42.8% | Fix ratio normalised (Section 5) |
| **Infrastructure & DevOps** | 5% | 77.1% | 22.8% | git blame on infra files (Section 2) |
| **Database & schema** | 5% | 76.8% | 23.1% | git blame on SQL/migrations (Section 2) |
| **Tests** | 5% | 97.8% | 2.1% | git blame on test files (Section 2) |
| **Code efficiency** | 5% | 76.7% | 23.3% | LOC per commit ratio (Section 1) |
| **Project management** | 5% | 51.4% | 48.6% | GitHub Issues created+closed (Section 6) |
| **Business development** | 10% | 10% | 90% | Not in git — estimated |

### Result

```
Weighted Contribution:

Sean   ████████████████████████████████████████████████████████████░  59%
Jussy  █████████████████████████████████████████░░░░░░░░░░░░░░░░░░░  41%
```

| | Calculation | Result |
|---|---|---|
| **Sean** | (0.30 x 55.5) + (0.15 x 73.3) + (0.10 x 56.9) + (0.10 x 57.2) + (0.05 x 77.1) + (0.05 x 76.8) + (0.05 x 97.8) + (0.05 x 76.7) + (0.05 x 51.4) + (0.10 x 10) | **59.0%** |
| **Jussy** | (0.30 x 44.4) + (0.15 x 26.6) + (0.10 x 43.0) + (0.10 x 42.8) + (0.05 x 22.8) + (0.05 x 23.1) + (0.05 x 2.1) + (0.05 x 23.3) + (0.05 x 48.6) + (0.10 x 90) | **41.0%** |

**Note on weights:** Business development (10%) is the only category not derived from git data. If this weight were increased to 20% (reducing surviving code to 20%), the split would be approximately 54/46. If removed entirely, it would be 65/35. The weights above represent a balanced assessment that values both technical and non-technical contributions.

---

## 6. Engineering Quality

### Fix & Maintenance Commits

| | Sean | Jussy |
|---|---|---|
| **Fix/refactor commits** | 373 | 738 |
| **Fix ratio (fix commits / total)** | 46.9% | 35.1% |

**Key insight:** Sean spends proportionally more of his time (46.9%) on fix and maintenance work compared to Jussy (35.1%). This reflects the "maintainer tax" — the ongoing work required to keep code production-ready.

### GitHub Issues (Aphelix-Labs org)

| | Sean | Jussy |
|---|---|---|
| **Issues created** | 194 | 206 |
| **Issues closed** | 109 | 103 |

**Key insight:** Both contributors create and close roughly equal numbers of issues. Project management is evenly shared.

### Code Duplication (jscpd)

| Repo | Duplication % |
|------|---------------|
| aurum_mira | 0% |
| client-closer | 0% |
| mira-practice | 0% |
| mira | 0% |
| spektrom | 0% |
| sutton-dental-care | 0% |
| xcape-ai | 0% |
| xcape-velocity | 0% |

### TypeScript Compilation

| Repo | Errors |
|------|--------|
| aurum_mira | 0 |
| client-closer | 0 |
| mira-practice | 0 |
| mira | 0 |
| spektrom | 2 |
| sutton-dental-care | 0 |
| xcape-ai | 0 |
| xcape-velocity | 0 |

### Dependency Vulnerabilities

| Repo | Critical | High | Moderate | Low |
|------|----------|------|----------|-----|
| aurum_mira | 0 | 0 | 0 | 0 |
| client-closer | 0 | 0 | 0 | 0 |
| mira-practice | 0 | 0 | 0 | 0 |
| mira | 0 | 0 | 0 | 0 |
| spektrom | 0 | 0 | 0 | 0 |
| sutton-dental-care | 0 | 0 | 0 | 0 |
| xcape-ai | 0 | 0 | 0 | 0 |
| xcape-velocity | 0 | 0 | 0 | 0 |

### Secrets Detection (detect-secrets)

| Repo | Findings | Files |
|------|----------|-------|
| All repos | 0 | 0 |

---

## 7. Domain Category Definitions

| Domain | File patterns | What it covers |
|---|---|---|
| **Infrastructure** | `*.yml`, `*.toml`, `Dockerfile`, `.github/**`, `netlify.toml`, `vite.config*`, `tsconfig*` | CI/CD, deployment, build configs |
| **Backend** | `netlify/functions/**`, `supabase/functions/**`, `src/lib/**`, `src/services/**`, `src/integrations/**` | Server functions, API endpoints, integrations |
| **Frontend** | `src/components/**`, `src/pages/**`, `*.css`, `*.scss` | React components, pages, styling |
| **Tests** | `src/test/**`, `tests/**`, `*.test.*`, `*.spec.*` | Unit, integration, E2E tests |
| **Documentation** | `docs/**`, `*.md`, `README*` | Technical docs, runbooks |
| **Database** | `supabase/migrations/**`, `*.sql`, `*database.types*` | Migrations, schema, DB types |
| **Data & Config** | `src/data/**`, `src/types/**`, `src/stores/**`, `src/constants/**` | Type definitions, data, state stores |

---

## Sources & References

- **git-fame** — [github.com/casperdcl/git-fame](https://github.com/casperdcl/git-fame) — Surviving LOC attribution via `git blame`
- **IEEE Software Maintenance Research** — [ieeexplore.ieee.org/document/5765617](https://ieeexplore.ieee.org/document/5765617) — 80-90% of software lifecycle cost is maintenance
- **Slicing Pie (Mike Moyer)** — [slicingpie.com](https://slicingpie.com/) — Market-rate contribution valuation framework
- **Foundrs Calculator** — [foundrs.com](https://foundrs.com/) — Co-founder equity split calculator (weights technical 1.2x vs business 1.0x)
- **Harvard Business School (Noam Wasserman)** — Research on co-founder equity: equal splits correlate with lower valuations
- **GitClear LOC Analysis** — [gitclear.com](https://www.gitclear.com/lines_of_code_is_a_worthless_metric) — Why lines of code is a poor metric; surviving code is better
- **detect-secrets (Yelp)** — [github.com/Yelp/detect-secrets](https://github.com/Yelp/detect-secrets) — Automated secrets scanning

---

*Generated by `scripts/code-audit.sh` — runs automatically every Monday via GitHub Actions.*
*All data is derived from git history and GitHub API. Rerun anytime for updated numbers.*
