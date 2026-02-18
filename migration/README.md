# PostgreSQL Migration Validation Hub (V1)

## Purpose

This directory is the entry point for Oracle -> PostgreSQL migration validation.
It helps DBAs and developers run a 360-degree health report, detect issues early, and apply fixes with clear guidance.

## How It Helps

- Gives one HTML report with `PASS / WARN / FAIL` checks.
- Shows actionable fix guidance for each detected issue.
- Includes a full test workflow: create issues, generate report, fix issues, regenerate report.
- Provides sample outputs to attach in PRs and release notes.

## V1 Assets

- Main script: `../27_migration_validation/01_oracle_to_postgres_360_health_report.sql`
- Seed issues: `../27_migration_validation/02_seed_v1_test_issues.sql`
- Fix issues: `../27_migration_validation/03_fix_v1_test_issues.sql`
- Sanity checks: `../27_migration_validation/04_v1_sanity_checks.sql`
- Detailed docs: `../27_migration_validation/README.md`
- Sample outputs: `../27_migration_validation/samples/`

## Quick Usage

Run from repository root (`postgres_admin_scripts` parent):

```bash
cd "/Users/saiendla/Documents/PostgreSQl SCripts "

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_360_migration_health_report.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"
```

## Full Validation Flow (Before/After)

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/02_seed_v1_test_issues.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v1_report_before_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/04_v1_sanity_checks.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/03_fix_v1_test_issues.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v1_report_after_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/04_v1_sanity_checks.sql"
```

## Git Push Checklist

- Include directory `27_migration_validation/` and this `migration/README.md`.
- Include sample output files under `27_migration_validation/samples/`.
- Confirm sanity result is `all_passed=YES` after fix flow.
- Add PR notes with before/after summary from sample reports.
