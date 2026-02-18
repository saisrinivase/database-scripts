# Oracle -> PostgreSQL Migration Validation (V1)

Purpose: generate a single HTML report that detects migration and operational risks and gives quick fix guidance.

## Files

- `01_oracle_to_postgres_360_health_report.sql`
  - Main report generator (`PASS/WARN/FAIL`, issue details, suggested fixes).
- `02_seed_v1_test_issues.sql`
  - Seeds deterministic problems in `migration_v1_lab` schema for testing.
- `03_fix_v1_test_issues.sql`
  - Resolves seeded problems.
- `04_v1_sanity_checks.sql`
  - PASS/FAIL assertions for seeded checks only.

## Prerequisites

- PostgreSQL 12+ (validated on PostgreSQL 18).
- `psql` client access.
- Role with enough visibility to query:
  - `pg_settings`
  - `pg_stat_activity`
  - `pg_stat_database`
  - `pg_stat_replication`
  - `pg_replication_slots`
- Recommended role memberships for full output:
  - `pg_monitor` (or superuser in controlled environments)
- Disk space for HTML outputs and test data (seed script creates sizable test tables).

## Main Usage

```bash
cd "/Users/saiendla/Documents/PostgreSQl SCripts "

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_360_migration_health_report.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"
```

## V1 End-to-End Test Workflow

### 1) Seed known issues

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/02_seed_v1_test_issues.sql"
```

### 2) Generate report with issues present

```bash
mkdir -p "postgres_admin_scripts/27_migration_validation/samples"

psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v1_report_before_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"
```

### 3) Run sanity checks (should show FAIL items before fix)

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/04_v1_sanity_checks.sql"
```

### 4) Apply fixes

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/03_fix_v1_test_issues.sql"
```

### 5) Generate report after fixes

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v1_report_after_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/01_oracle_to_postgres_360_health_report.sql"
```

### 6) Run sanity checks again (target: all PASS)

```bash
psql "host=<host> port=<port> dbname=<db> user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/04_v1_sanity_checks.sql"
```

## Expected Report Sections

- `Report Metadata`
- `Overall Health Summary`
- `360-Degree Check Results`
- `Issue Details (Top Objects and Sessions)`

## Included Sample Outputs

- `samples/v1_report_before_fix.html`
- `samples/v1_report_after_fix.html`
- `samples/v1_sanity_before_fix.txt`
- `samples/v1_sanity_after_fix.txt`
- `samples/README.md` (quick summary of before/after results)

## Common Oracle -> PostgreSQL Pitfalls (Datatype/Casting)

- Oracle `DATE` includes time; PostgreSQL `date` does not.
- Oracle empty string (`''`) behaves like `NULL`; PostgreSQL keeps empty string as value.
- Oracle implicit casting is looser; PostgreSQL requires explicit, type-safe casts.
- `NUMBER` mapped to small integer types can overflow; use proper `numeric(p,s)` where needed.
- `NVL`/`DECODE` rewrites can fail when branch types differ; normalize with explicit casts.
- `TIMESTAMP WITH LOCAL TIME ZONE` mapping needs `timestamptz` and timezone policy checks.
- Mixed-type joins (`text` vs `bigint`, etc.) can break plan quality and correctness.
- Uppercase quoted identifiers increase SQL fragility.

## V1 Release Checklist

- [ ] Report script runs with `ON_ERROR_STOP=1` on target environment.
- [ ] Sanity checks pass after running `03_fix_v1_test_issues.sql`.
- [ ] Attach both sample reports:
  - `samples/v1_report_before_fix.html`
  - `samples/v1_report_after_fix.html`
- [ ] Keep command history/log output for reproducibility in PR description.
- [ ] Review WARN/FAIL checks that are environment-level (for example replication topology) before sign-off.
