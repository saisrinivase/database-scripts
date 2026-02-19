# PostgreSQL Migration Validation Hub

## Purpose

This directory is the entry point for Oracle -> PostgreSQL migration validation and takeover gating.
It helps DBAs and developers detect risks, validate fixes, and decide cutover readiness using reproducible SQL evidence.

## How It Helps

- V1 baseline 360 report for broad risk visibility.
- V2 enterprise report with practical seeded issue lab coverage.
- V3 takeover gate with explicit `GO / CONDITIONAL_GO / NO_GO` decision logic.
- Reproducible sample outputs for PR and release evidence.

## Versioned Assets

- V1 baseline:
  - `../27_migration_validation/01_oracle_to_postgres_360_health_report.sql`
  - `../27_migration_validation/02_seed_v1_test_issues.sql`
  - `../27_migration_validation/03_fix_v1_test_issues.sql`
  - `../27_migration_validation/04_v1_sanity_checks.sql`
- V2 enterprise:
  - `../27_migration_validation/05_seed_v2_test_issues.sql`
  - `../27_migration_validation/06_fix_v2_test_issues.sql`
  - `../27_migration_validation/07_v2_sanity_checks.sql`
  - `../27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql`
- V3 decision gate:
  - `../27_migration_validation/09_enterprise_takeover_gate_v3.sql`
- Common docs and outputs:
  - `../27_migration_validation/README.md`
  - `../27_migration_validation/samples/`

## Quick Usage (V3 Gate - Recommended for Cutover Decision)

Run from repository root (`postgres_admin_scripts` parent):

```bash
cd "/Users/saiendla/Documents/PostgreSQl SCripts "

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v critical_schema_regex='^public$' \
  -v enforce_exit=true \
  -f "postgres_admin_scripts/27_migration_validation/09_enterprise_takeover_gate_v3.sql"
```

## Full Validation Flow (V2 + V3)

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/05_seed_v2_test_issues.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v2_report_before_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/07_v2_sanity_checks.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/06_fix_v2_test_issues.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v2_report_after_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/07_v2_sanity_checks.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v critical_schema_regex='^public$' \
  -v enforce_exit=true \
  -f "postgres_admin_scripts/27_migration_validation/09_enterprise_takeover_gate_v3.sql"
```

## Git Push Checklist

- Include `27_migration_validation/` and `migration/README.md`.
- Include sample outputs under `27_migration_validation/samples/`.
- Confirm V2 sanity result `all_passed=YES` after fix flow.
- Attach V3 gate decision output (`GO`, `CONDITIONAL_GO`, or `NO_GO`) to PR notes.
