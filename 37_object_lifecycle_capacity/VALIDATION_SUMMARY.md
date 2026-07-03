# Object Lifecycle Capacity Validation Summary

Purpose: Record the validation flow for object lifecycle, index lifecycle, growth, monthly reporting, and action advisory scripts.

## Validation Date

- Validated locally on PostgreSQL using `psql -X -v ON_ERROR_STOP=1`.
- Target compatibility: PostgreSQL 15+.
- All tracked SQL scripts in this folder are plain SQL/PLpgSQL compatible and do not require psql-only branching.

## Scripts Validated In Order

| Step | Script | Result | What Was Verified |
| ---: | --- | --- | --- |
| 1 | `01_create_lifecycle_repository.sql` | PASS | Repository schema, capture tables, DDL log, snapshot tables, and supporting indexes create idempotently. |
| 2 | `02_create_ddl_event_triggers.sql` | PASS | Event trigger functions and DDL/drop triggers create or replace successfully when privileges allow. |
| 3 | `03_create_snapshot_procedures.sql` | PASS | Snapshot and purge procedures compile successfully. |
| 4 | `04_capture_snapshot_now.sql` | PASS | Manual snapshot capture inserts run metadata plus index, table, object, and tablespace rows. |
| 5 | `05_create_index_lifecycle_views.sql` | PASS | Index lifecycle views create and return lifecycle output. |
| 6 | `06_create_table_modification_views.sql` | PASS | Table DML delta and monthly modification views create successfully. |
| 7 | `07_create_growth_views.sql` | PASS | Monthly database and object growth views create successfully. |
| 8 | `08_create_action_advisory_views.sql` | PASS | Capacity action queue view creates successfully from lifecycle, growth, and DML sources. |
| 9 | `09_scheduler_runbook.sql` | PASS | Scheduler readiness and recommended capture/purge commands render successfully. |
| 10 | `10_monthly_capacity_report.sql` | PASS | Monthly report sections render with prerequisites, growth percentages, severities, actions, and next steps. |
| 11 | `11_index_usage_lab_create_use_drop_demo.sql` | PASS | Demo table/index lifecycle creates, uses, captures, and reports index lifecycle behavior. |
| 12 | `12_table_modification_tracking_demo.sql` | PASS | Demo DML workload captures before/after table modification deltas. |

## Post-Validation View Checks

After running the full flow, these lifecycle views were queried and returned rows:

| View | Expected Purpose |
| --- | --- |
| `dba_metrics.vw_index_lifecycle` | Index first/last seen, scans, DDL evidence, and lifecycle status. |
| `dba_metrics.vw_table_modification_delta` | Per-snapshot insert/update/delete/HOT/dead tuple deltas. |
| `dba_metrics.vw_table_modifications_monthly` | Monthly DML pressure rollup by table. |
| `dba_metrics.vw_database_growth_monthly` | Monthly database growth. |
| `dba_metrics.vw_object_growth_monthly` | Monthly table/index/TOAST/sequence/materialized view growth. |
| `dba_metrics.vw_capacity_action_queue` | Prioritized capacity and lifecycle action queue. |

## Hygiene Checks

- No tracked lifecycle SQL file contains psql-only `\gset`, `\if`, `\else`, `\endif`, or `\set` directives.
- No tracked lifecycle SQL file contains non-ASCII characters.
- Every tracked lifecycle SQL file includes `Purpose:` and `SAMPLE_OUTPUT_BEGIN`.
- `git diff --check` passed.

## Local Duplicate Note

The local workspace contains an untracked file named `10_monthly_capacity_report 2.sql`. It is an older, shorter duplicate of the tracked `10_monthly_capacity_report.sql`.
The tracked version is the current validated report and should be used for repository work.
