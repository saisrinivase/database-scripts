# PostgreSQL Scripts Production-Readiness Audit

Audit date: 2026-08-19

Repository branch: `postgres`

Starting commit: `c841ebb`
Local validation engine: PostgreSQL 18.3

## Outcome

All 274 SQL scripts were inventoried and assigned execution placement, scale
confidence, prerequisites, risk flags, and three runtime results in
`script-safety-matrix.tsv`.

This audit does not claim that a small local database proves 50 TB performance.
The 10 TB and 50 TB confidence columns classify the work performed by each
script: bounded statistics/catalog reads, object-count-proportional work,
filesystem size traversal, data scans, interval sampling, or destructive labs.

## Three validation gates

| Gate | Result | What it proves |
| --- | ---: | --- |
| Disposable database with 20 s statement, 1 s lock, and 256 MB temp limits | 273 pass, 1 deliberately skipped | Syntax/runtime and prerequisite workflow on PostgreSQL 18.3 |
| Read-only transaction after prerequisites | 213 pass, 61 fail as writer-only | Physical-reader compatibility and mutation detection |
| Read-only `pg_monitor` role | 209 pass, 65 fail | Least-privilege compatibility and explicit elevated requirements |

The skipped script is
`05_partitioning/07_partition_lab_generate_5gb_timeseries.sql`. It drops and
recreates a persistent unlogged table and writes at least 5 GiB, so it is
prohibited on production writer and reader instances.

## Placement summary

| Placement | Scripts | Meaning |
| --- | ---: | --- |
| `WRITER_ONLY` | 61 | Persistent/session DDL or writes; read-only execution rejected |
| `WRITER_REQUIRED` | 21 | Writer-local DML, vacuum, XID, WAL, or maintenance state is authoritative |
| `WRITER_PREFERRED` | 16 | Primary-side WAL/archive/cluster evidence |
| `READER_PREFERRED` | 1 | Standby receive/replay evidence |
| `RUN_ON_BOTH` | 7 | Compare primary and standby evidence |
| `TARGET_INSTANCE` | 79 | Runtime statistics are instance-local; run where the workload occurred |
| `EITHER_METADATA` | 89 | Metadata may be offloaded to a current reader |

Important: `pg_stat_activity`, `pg_stat_statements`, table/index access counters,
wait events, and I/O counters are instance-local. Running those scripts on a
reader does not diagnose writer workload.

## Scale-confidence summary

| Confidence | 10 TB | 50 TB |
| --- | ---: | ---: |
| High | 242 | 78 |
| Medium-high | 27 | 164 |
| Medium | 0 | 27 |
| Low | 2 | 2 |
| Not production eligible | 3 | 3 |

The 50 TB rating is intentionally more conservative because relation-size and
database-size functions can traverse large numbers of relation segment files,
and catalog-wide queries can become expensive on fleets with very high object
counts.

## High-risk scripts

### Never run on production

- `05_partitioning/07_partition_lab_generate_5gb_timeseries.sql`: drops and
  recreates a persistent table and loads at least 5 GiB.
- `37_object_lifecycle_capacity/11_index_usage_lab_create_use_drop_demo.sql`:
  creates, loads, indexes, queries, and drops lab objects.
- `37_object_lifecycle_capacity/12_table_modification_tracking_demo.sql`:
  performs demonstration INSERT/UPDATE/DELETE activity.

### Data-volume-proportional scans

- `04_toast_lob_blob/03_large_objects_summary.sql`
- `04_toast_lob_blob/04_top_large_objects.sql`

Both scan `pg_largeobject`; neither is approved for an unbounded production run
at 10 TB or 50 TB. They also require explicit access to `pg_largeobject`, which
`pg_monitor` does not provide.

### Schedule or timeout-control on very large/file-dense systems

- Database, table, TOAST, partition, fork, and capacity scripts marked
  `SIZE_CALL` or `SIZE_CALL_LOOP` in the matrix.
- `41_aws_rds_aurora_postgresql/12_buffer_cache_read_write_iops_deep_dive.sql`
  intentionally sleeps for an interval and requires a writer because it creates
  session-local objects.

## Confirmed defects fixed

1. `17_execution_plans/03_generate_explain_for_top_queries.sql`
   previously generated `EXPLAIN ANALYZE` for captured INSERT/UPDATE/DELETE SQL.
   Following that output could execute production DML. It now generates only
   non-executing `EXPLAIN`, excludes unsupported utility commands, and flags bind
   placeholders.
2. `38_observability_360/06_table_index_activity_heatmap.sql` converted schema
   text back to `regclass`, failing for `pg_monitor` when unrelated schemas lacked
   `USAGE`. It now uses relation OIDs and computes relation size once.
3. `01_database_size/01_databases_size.sql` repeatedly invoked
   `pg_database_size()` for each database. It now evaluates the filesystem size
   once per database and documents low-load-window/timeout guidance.

## Extension diagnostics added

- `07_vacuum_bloat/06_pgstattuple_safe_bloat_candidates.sql` ranks candidates
  from writer-local statistics and generates opt-in `pgstattuple_approx()`
  commands. It never invokes `pgstattuple()` or scans table data automatically.
- `31_logging_error_signatures/05_pgaudit_readiness_and_configuration.sql`
  reports package, preload, database-extension, and GUC readiness without
  failing when pgAudit is absent. Audit events must be retrieved from the
  PostgreSQL external log destination; pgAudit does not store an event table.

Both scripts passed normal, read-only, and `pg_monitor` execution. In addition,
`pgstattuple_approx()` was exercised directly against the 312 MB
`pgbenchc_test.public.pgbench_accounts` table. pgAudit was not installed because
the package is unavailable in the local PostgreSQL 18.3 installation and adding
it would require a server package, preload configuration, and restart.

## Known privilege requirements

These remain intentional and must be documented in the deployment runbook:

- `04_toast_lob_blob/03_large_objects_summary.sql` and `04_top_large_objects.sql`:
  explicit `pg_largeobject` read permission.
- `32_upgrade_patch_readiness/06_config_file_unknown_or_deprecated_gucs.sql`:
  access to `pg_file_settings`.
- `42_problem_identification_internals/03_logical_replication_cdc_health.sql`:
  elevated access to `pg_subscription` for subscription details.

## Production execution baseline

Use a dedicated monitoring role and set safeguards per session:

```sql
SET statement_timeout = '30s';
SET lock_timeout = '2s';
SET idle_in_transaction_session_timeout = '60s';
```

For large-size inventory, run one script at a time during low load, record elapsed
time and buffer/I/O impact, and stop if replica lag, storage latency, or queue
depth increases. Never run the complete repository as one production batch.

## Evidence files

- `script-safety-matrix.tsv`: one row for every SQL script.
- `results-disposable-final/disposable-results.tsv`: bounded full workflow.
- `results-readonly-after-setup/readonly-results.tsv`: reader gate.
- `results-pg-monitor-final/readonly-results.tsv`: least-privilege gate.
- `validate_disposable.sh` and `validate_readonly.sh`: repeatable harnesses.

PostgreSQL 15, 16, and 17 were statically reviewed but were not available for
runtime execution in this workspace. Therefore, this audit does not label those
versions runtime-certified; version-specific CI remains a required follow-up.
