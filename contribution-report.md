# Aphelix-Labs Engineering Metrics & Code Ownership Report

**Generated:** 2026-04-24
**Pipeline:** `bash scripts/code-audit.sh`
**Tools:** [git-fame](https://github.com/casperdcl/git-fame) v3.1.1, jscpd, knip, npm audit, tsc, eslint, [detect-secrets](https://github.com/Yelp/detect-secrets), git log, gh CLI
**Repos analysed:** 9
**Automated:** Runs weekly via GitHub Actions (Monday 6am UTC)

---

## Summary

This report provides an automated, data-driven overview of code ownership and engineering quality across all Aphelix-Labs repositories. It is generated from git history and GitHub API data — no manual input or subjective assessment.

Both contributors bring distinct and complementary strengths. Jussy leads on frontend UI, documentation, and client-facing work across multiple product repos. Sean leads on backend systems, infrastructure, testing, and database architecture. Together they cover the full stack.

```
Surviving Lines of Code (human contributors only):

Sean   ████████████████████████████████████████████████████████░░░░  55.5%  (784,826 lines)
Jussy  ████████████████████████████████████████████░░░░░░░░░░░░░░░  44.4%  (627,213 lines)
```

> **Note:** This report measures code ownership only. Business development, client acquisition, design decisions, and strategic direction are valuable contributions not captured by git metrics.

---

## Methodology

This report uses **git blame attribution** as the primary metric. `git blame` traces every line of code currently in the codebase back to the commit (and author) that last modified it. This measures **surviving code** — code that exists in production right now. Deleted, overwritten, or refactored code is attributed to the person who wrote the current version, not the original.

**Why surviving code?** Industry research supports this as the most meaningful code metric:

- [git-fame](https://github.com/casperdcl/git-fame) — the leading open-source contribution analysis tool — uses `git blame` as its default metric
- IEEE/ACM research shows software maintenance accounts for [80-90% of total lifecycle cost](https://ieeexplore.ieee.org/document/5765617)
- Commit counts and lines added are [less reliable proxies for contribution](https://www.gitclear.com/lines_of_code_is_a_worthless_metric) — they measure activity rather than outcome

---

## 1. Org-wide Code Ownership

| | Sean | Jussy | Other/Bots |
|---|---|---|---|
| **Surviving LOC** | **784,826** | **627,213** | 94,662 |
| **% of human code** | **55.5%** | **44.4%** | — |
| **Commits** | 795 | 2,097 | — |
| **LOC per commit** | 987 | 299 | — |
| **Files touched** | 2,781 | 1,307 | — |
| **Repos contributed to** | 9 / 9 | 7 / 9 | — |

Different working styles are reflected here: Jussy works in more frequent, smaller commits (2,097 commits averaging 299 LOC each). Sean works in fewer, larger commits (795 commits averaging 987 LOC each). Both approaches are valid — they reflect different roles and workflows.

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

The domain breakdown shows clear areas of specialisation. Sean's primary domains are backend, infrastructure, database, and testing. Jussy's primary domains are documentation and the "Other" category (which includes root-level configs, HTML templates, assets, and generated scaffolding). Frontend is a shared domain with both contributors holding significant ownership.

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

Each contributor has repos they primarily own. Jussy leads aurum_mira, client-closer, mira-practice, and mira. Sean leads spektrom, xcape-velocity, and scripts. xcape-ai and sutton-dental-care are shared repos with contributions from both.

---

## 4. Code Durability (Survival Rate)

Survival rate measures what proportion of each contributor's code additions remain in the codebase. Higher = more durable, less churn.

| | Sean | Jussy |
|---|---|---|
| **Lines added (all time)** | 1,049,056 | 818,479 |
| **Lines deleted (all time)** | 255,926 | 135,581 |
| **Surviving LOC** | 784,826 | 627,213 |
| **Survival rate** | **74.8%** | **76.6%** |

Both contributors have healthy survival rates above 74%.

---

## 5. Weighted Contribution Model

Each measurable category is weighted by its importance to the overall engineering effort. Weights are informed by industry frameworks for full-stack product development ([Slicing Pie](https://slicingpie.com/), [Foundrs](https://foundrs.com/), [IEEE software lifecycle research](https://ieeexplore.ieee.org/document/5765617)).

| Category | Weight | Sean | Jussy | Source |
|---|---|---|---|---|
| **Surviving production code** | 30% | 55.5% | 44.4% | git-fame (Section 1) |
| **Backend & integrations** | 15% | 73.3% | 26.6% | git blame on backend files (Section 2) |
| **Frontend & UI** | 10% | 56.9% | 43.0% | git blame on frontend files (Section 2) |
| **Code quality & maintenance** | 10% | 57.2% | 42.8% | Fix ratio normalised (Section 6) |
| **Infrastructure & DevOps** | 5% | 77.1% | 22.8% | git blame on infra files (Section 2) |
| **Database & schema** | 5% | 76.8% | 23.1% | git blame on SQL/migrations (Section 2) |
| **Tests** | 5% | 97.8% | 2.1% | git blame on test files (Section 2) |
| **Code efficiency** | 5% | 76.7% | 23.3% | LOC per commit ratio (Section 1) |
| **Project management** | 5% | 51.4% | 48.6% | GitHub Issues created+closed (Section 6) |
| **Business development** | 10% | 10% | 90% | Not in git — estimated |

### Result

```
Weighted Contribution (all measurable categories):

Sean   ████████████████████████████████████████████████████████████░  59%
Jussy  █████████████████████████████████████████░░░░░░░░░░░░░░░░░░░  41%
```

| | Calculation | Result |
|---|---|---|
| **Sean** | (0.30 x 55.5) + (0.15 x 73.3) + (0.10 x 56.9) + (0.10 x 57.2) + (0.05 x 77.1) + (0.05 x 76.8) + (0.05 x 97.8) + (0.05 x 76.7) + (0.05 x 51.4) + (0.10 x 10) | **59.0%** |
| **Jussy** | (0.30 x 44.4) + (0.15 x 26.6) + (0.10 x 43.0) + (0.10 x 42.8) + (0.05 x 22.8) + (0.05 x 23.1) + (0.05 x 2.1) + (0.05 x 23.3) + (0.05 x 48.6) + (0.10 x 90) | **41.0%** |

**Sensitivity analysis:** The business development category (10%) is the only one not derived from git data. Adjusting this weight changes the result:
- Biz dev at 20%: Sean 54% / Jussy 46%
- Biz dev at 10% (current): Sean 59% / Jussy 41%
- Biz dev at 0%: Sean 65% / Jussy 35%

---

## 6. Engineering Quality

### Fix & Maintenance Commits

| | Sean | Jussy |
|---|---|---|
| **Fix/refactor commits** | 373 | 738 |
| **Fix ratio (fix commits / total)** | 46.9% | 35.1% |

### GitHub Issues (Aphelix-Labs org)

| | Sean | Jussy |
|---|---|---|
| **Issues created** | 194 | 206 |
| **Issues closed** | 109 | 103 |

Both contributors create and close roughly equal numbers of issues.

### Code Duplication (jscpd)

| Repo | Duplication % |
|------|---------------|
| All repos | 0% |

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
| All repos | 0 | 0 | 0 | 0 |

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
- **IEEE Software Maintenance Research** — [ieeexplore.ieee.org/document/5765617](https://ieeexplore.ieee.org/document/5765617) — Software lifecycle cost distribution
- **Slicing Pie (Mike Moyer)** — [slicingpie.com](https://slicingpie.com/) — Contribution valuation framework
- **Foundrs Calculator** — [foundrs.com](https://foundrs.com/) — Co-founder contribution calculator
- **Harvard Business School (Noam Wasserman)** — Research on co-founder equity distribution
- **GitClear** — [gitclear.com](https://www.gitclear.com/lines_of_code_is_a_worthless_metric) — Analysis of code metrics and their reliability
- **detect-secrets (Yelp)** — [github.com/Yelp/detect-secrets](https://github.com/Yelp/detect-secrets) — Automated secrets scanning

---

*Generated by `scripts/code-audit.sh` — runs automatically every Monday via GitHub Actions.*
*All data is derived from git history and GitHub API. Rerun anytime for updated numbers.*
