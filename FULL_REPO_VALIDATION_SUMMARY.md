# Full Repository SQL Validation Summary

Purpose: Record repository-wide SQL validation for the PostgreSQL branch.

## Validation Date

- Date: 2026-07-03
- Branch: `postgres`
- Database used: local `postgres`
- Command style: `psql -X -v ON_ERROR_STOP=1 -d postgres -f <script>`

## Result

| Scope | Scripts | Passed | Failed |
| --- | ---: | ---: | ---: |
| All tracked SQL files from `git ls-files '*.sql'` | 247 | 247 | 0 |

## What Was Included

- Every tracked SQL script from `00_environment` through `40_pgadmin_safe_diagnostics`.
- Repository setup scripts.
- Snapshot/capture scripts.
- View creation scripts.
- Reporting scripts.
- Lab/demo scripts, including partition and lifecycle demos.
- PgAdmin-safe diagnostics.
- Observer-agent and lifecycle repository workflows.

## Hygiene Checks

| Check | Result |
| --- | --- |
| psql-only meta directives in tracked SQL (`\gset`, `\if`, `\else`, `\endif`, `\set`) | PASS: none found |
| Non-ASCII / emoji characters in tracked SQL | PASS: none found |
| Git whitespace check | PASS |

## Notes

- The validation loop used only tracked SQL files, so local untracked files were not counted.
- The local workspace still contains an untracked older duplicate: `37_object_lifecycle_capacity/10_monthly_capacity_report 2.sql`.
- The tracked and validated lifecycle monthly report is `37_object_lifecycle_capacity/10_monthly_capacity_report.sql`.
- Some scripts intentionally create repository, lab, trigger, snapshot, or demo objects as part of their documented purpose.
