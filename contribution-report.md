# Aphelix-Labs Engineering Metrics & Code Ownership Report

**Generated:** 2026-04-24
**Pipeline:** `bash scripts/code-audit.sh`
**Tools:** git-fame, jscpd, knip, npm audit, tsc, eslint, detect-secrets, git log, gh CLI
**Repos analysed:** 9

---

## Methodology

This report uses **git blame attribution** as the primary metric. `git blame` traces every line of code currently in the codebase back to the commit (and author) that last modified it. This measures **surviving code** — code that exists in production right now. Deleted, overwritten, or refactored code is attributed to the person who wrote the current version, not the original.

This is the industry-standard metric used by [git-fame](https://github.com/casperdcl/git-fame), the leading open-source contribution analysis tool. It is more meaningful than commit counts or lines added, because it measures **what remains** rather than what was attempted.

---

## 1. Org-wide Code Ownership (Surviving LOC)

| | Sean | Jussy | Other/Bots |
|---|---|---|---|
| **Surviving LOC** | **784826** | **627213** | 94662 |
| **% of human code** | **55.5%** | **44.4%** | — |
| **Commits** | 795 | 2097 | — |
| **LOC per commit** | **987** | 299 | — |
| **Files touched** | 2781 | 1307 | — |
| **Repos contributed to** | 9 / 9 | 7 / 9 | — |

---

## 2. Code Ownership by Domain

Surviving lines attributed by file category across all repos.

| Domain | Sean LOC | Jussy LOC | Sean % | Jussy % |
|---|---|---|---|---|
| **Infrastructure** | 2650 | 784 | 77.1% | 22.8% |
| **Backend** | 83204 | 30276 | 73.3% | 26.6% |
| **Frontend** | 245579 | 185715 | 56.9% | 43.0% |
| **Tests** | 34910 | 785 | 97.8% | 2.1% |
| **Documentation** | 68086 | 78596 | 46.4% | 53.5% |
| **Database** | 44644 | 13412 | 76.8% | 23.1% |
| **Data Config** | 32707 | 13025 | 71.5% | 28.4% |
| **Other** | 273046 | 304620 | 47.2% | 52.7% |
| **TOTAL** | **784826** | **627213** | **55.5%** | **44.4%** |

---

## 3. Per-repo Code Ownership

| Repo | Total LOC | Sean LOC (%) | Jussy LOC (%) | Other (%) |
|------|-----------|-------------|--------------|-----------|
| aurum_mira | 142216 | 14491 (10.1%) | 123624 (86.9%) | 4101 (2.8%) |
| client-closer | 339395 | 16982 (5.0%) | 303453 (89.4%) | 18960 (5.5%) |
| mira-practice | 46202 | 8328 (18.0%) | 36641 (79.3%) | 1233 (2.6%) |
| mira | 64390 | 10445 (16.2%) | 49657 (77.1%) | 4288 (6.6%) |
| scripts | 774 | 770 (99.4%) | 0 (0.0%) | 4 (0.5%) |
| spektrom | 289171 | 286528 (99.0%) | 0 (0.0%) | 2643 (0.9%) |
| sutton-dental-care | 45810 | 5643 (12.3%) | 19723 (43.0%) | 20444 (44.6%) |
| xcape-ai | 320246 | 196213 (61.2%) | 89824 (28.0%) | 34209 (10.6%) |
| xcape-velocity | 258497 | 245426 (94.9%) | 4291 (1.6%) | 8780 (3.3%) |

---

## 4. Code Durability (Survival Rate)

Survival rate = surviving LOC / total lines added. Higher = more of your code stays in production.

| | Sean | Jussy |
|---|---|---|
| **Lines added (all time)** | 1049056 | 818479 |
| **Lines deleted (all time)** | 255926 | 135581 |
| **Surviving LOC** | 784826 | 627213 |
| **Survival rate** | **74.8%** | **76.6%** |

---

## 5. Engineering Quality

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
| aurum_mira | 0 | 0 |
| client-closer | 0 | 0 |
| mira-practice | 0 | 0 |
| mira | 0 | 0 |
| scripts | 0 | 0 |
| spektrom | 0 | 0 |
| sutton-dental-care | 0 | 0 |
| xcape-ai | 0 | 0 |
| xcape-velocity | 0 | 0 |


---

## 6. Domain Category Definitions

| Domain | File patterns | What it covers |
|---|---|---|
| **Infrastructure** | `*.yml`, `*.toml`, `Dockerfile`, `.github/**`, `netlify.toml`, `vite.config*`, `tsconfig*` | CI/CD, deployment, build configs |
| **Backend** | `netlify/functions/**`, `supabase/functions/**`, `src/lib/**`, `src/services/**`, `src/integrations/**` | Server functions, API endpoints, integrations |
| **Frontend** | `src/components/**`, `src/pages/**`, `*.css`, `*.scss` | React components, pages, styling |
| **Tests** | `src/test/**`, `tests/**`, `*.test.*`, `*.spec.*` | Unit, integration, E2E tests |
| **Documentation** | `docs/**`, `*.md`, `README*` | Technical docs, runbooks |
| **Database** | `supabase/migrations/**`, `*.sql`, `*database.types*` | Migrations, schema, DB types |
| **Data & Config** | `src/data/**`, `src/types/**`, `src/stores/**`, `src/constants/**` | Type definitions, data, state stores |

> **Note:** Business development, client outreach, and design decisions are valuable contributions not captured by git metrics. This report measures code ownership only.

---

*Generated by `scripts/code-audit.sh` — rerun anytime for updated numbers.*
*Uses [git-fame](https://github.com/casperdcl/git-fame) v3.1.1 for git blame attribution.*
