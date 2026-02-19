# Oracle -> PostgreSQL Migration Validation

Purpose: provide deterministic issue simulation + enterprise-style reporting for migration and post-migration performance risk validation.

## Tracks

- `V1 Baseline`: quick 360 report + seeded core migration issues.
- `V2 Enterprise`: deeper object coverage, practical issue lab, and clearer issue playbook guidance.

## Files

### V1 Baseline

- `01_oracle_to_postgres_360_health_report.sql`
- `02_seed_v1_test_issues.sql`
- `03_fix_v1_test_issues.sql`
- `04_v1_sanity_checks.sql`

### V2 Enterprise / Practical

- `05_seed_v2_test_issues.sql`
  - Seeds practical issues in `migration_v2_lab` (PK/FK/index/casing/sequence/stats/bloat/datatype/search).
- `06_fix_v2_test_issues.sql`
  - Fixes V2 seeded issues.
- `07_v2_sanity_checks.sql`
  - PASS/FAIL assertions for V2 controls.
- `08_oracle_to_postgres_enterprise_report_v2.sql`
  - Styled HTML report with object coverage matrix and issue playbook.
- `ISSUE_CATALOG_V2.md`
  - Enterprise-style issue catalog (impact, coverage, detect/fix mapping).

## Target Database

Use your practical dataset database (`pgbench_test`) for realistic validation.

## V2 End-to-End Workflow (Recommended)

### 1) Seed practical issues

```bash
psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/05_seed_v2_test_issues.sql"
```

### 2) Generate enterprise report (before fix)

```bash
mkdir -p "postgres_admin_scripts/27_migration_validation/samples"

psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v2_report_before_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql"
```

### 3) Run sanity checks (expect FAIL items before fix)

```bash
psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/07_v2_sanity_checks.sql"
```

### 4) Apply fixes

```bash
psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/06_fix_v2_test_issues.sql"
```

### 5) Re-run report after fix

```bash
psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -v report_file='postgres_admin_scripts/27_migration_validation/samples/v2_report_after_fix.html' \
  -f "postgres_admin_scripts/27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql"
```

### 6) Re-run sanity checks (target: all PASS)

```bash
psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
  -f "postgres_admin_scripts/27_migration_validation/07_v2_sanity_checks.sql"
```

## V2 Object Coverage Scope

The enterprise report includes inventory and guidance for:

- `TABLE`
- `VIEW`
- `MVIEW`
- `TABLESPACE`
- `SEQUENCE`
- `INDEXES`
- `TRIGGER`
- `GRANT`
- `FUNCTION`
- `PROCEDURE`
- `PARTITION`
- `TYPE`
- `FDW`
- `QUERY` telemetry (`pg_stat_statements`)
- `INSERT/COPY` signal (when statement telemetry is available)
- Oracle mappings noted explicitly:
  - `PACKAGE` -> mapped guidance (`schema + function/procedure`)
  - `SYNONYM` -> mapped guidance (`view + search_path`)
  - `KETTLE` -> external integration note (not introspected via PostgreSQL catalogs)

## Notes

- V2 seed/fix scripts are isolated to `migration_v2_lab`.
- Environment-level checks (for example `autovacuum`, `track_io_timing`, extension baseline) are reported but not auto-seeded.
- Keep generated HTML and sanity outputs as PR/release evidence.
