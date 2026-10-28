# Enterprise Diagnostic Validation Harness

Purpose: execute the repository's non-stateful PostgreSQL diagnostic scripts in a transaction that is always rolled back, then record a machine-readable evidence report.

## Why this exists

SQL diagnostics must be validated against the PostgreSQL version, extension set, permissions, and managed-service limitations that will exist in production. A successful parse is not enough: a catalog column can be version-specific, a statistics view can need `pg_monitor`, and an extension can be absent.

The harness provides repeatable proof without leaving permanent objects or data changes behind. It works with a local server, on-premises PostgreSQL, or a managed service reachable with `psql`.

## Safe default run

```bash
python3 43_enterprise_diagnostic_harness/validate_diagnostics.py \
  --database postgres \
  --report-dir _validation_runs/local-$(date +%Y%m%d-%H%M%S)
```

By default the harness excludes persistent repository workflows in areas `15_capacity_forecasting`, `37_object_lifecycle_capacity`, and `39_observer_agent_monitoring`, and excludes intentional lab/data-generator files. Every selected script runs in its own transaction with a short `lock_timeout` and `statement_timeout`, followed by `ROLLBACK`.

Temporary tables and `pg_temp` helper functions are allowed because they disappear with the validation session. This makes the existing diagnostic style testable without changing the scripts themselves.

## Useful modes

```bash
# Validate one diagnostic area.
python3 43_enterprise_diagnostic_harness/validate_diagnostics.py \
  --database postgres --path 42_problem_identification_internals

# Test a single script after an edit.
python3 43_enterprise_diagnostic_harness/validate_diagnostics.py \
  --database postgres \
  --path 42_problem_identification_internals/08_snapshot_conflict_and_standby_cancel_triage.sql

# Include workflows that need their prerequisite repository objects.
python3 43_enterprise_diagnostic_harness/validate_diagnostics.py \
  --database postgres --include-stateful
```

Use the normal `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, SSL, and service-file environment variables supported by `psql`. Do not place passwords in command history or reports.

## Outputs and interpretation

The report directory receives `report.json` and `report.md`. Each script is classified as `PASS`, `FAIL`, or `TIMEOUT`; failures include stderr, so a DBA can distinguish SQL defects from expected capability or privilege gaps.

Run this in CI for every supported major version (15, 16, 17, 18) using a least-privileged monitoring role and an elevated DBA role. A script is production-ready only when its expected outcome is documented for both roles and for the cloud platforms it claims to support.

The harness validates execution and rollback behavior. It does not prove that an operational recommendation is correct for a workload; validate recommendations with baselines, `EXPLAIN (ANALYZE, BUFFERS)`, change control, and before/after evidence.

See `DIAGNOSTIC_ACCURACY_MODEL.md` for the evidence classes, realistic confidence ranges, and mandatory CPU/memory interpretation boundaries.

## Stateful workflow validation

`validate_stateful_workflows.py` validates the capacity, lifecycle, and observer repositories in a database that is explicitly marked disposable. These workflows intentionally create schemas, tables, functions, views, and event triggers, so they must never run against a production database.

```bash
createdb database_scripts_ci
python3 43_enterprise_diagnostic_harness/validate_stateful_workflows.py \
  --database database_scripts_ci --confirm-ephemeral
dropdb database_scripts_ci
```

The GitHub Actions matrix in `.github/workflows/postgresql-validation.yml` runs the SQL contract check, rollback-safe diagnostics, and stateful workflow validation against PostgreSQL 15, 16, 17, and 18.

Routine CI intentionally excludes three resource-heavy demonstrations: the 5GB partition generator and the two object-lifecycle create/use/drop demos. The stateful harness validates that every script in its managed folders is either executed or named in its explicit exclusion set.

## History-window policy

Current diagnostic scripts do not impose a global three-month reporting window. Snapshot history reports use all stored captures; retention is an operational policy, not a query filter. The contract linter rejects a fixed `3 months` or `90 days` SQL interval unless the script explicitly documents it as a `History Window:` or retention policy.
