# Cross-database and diagnostic-accuracy certification

Certification date: 2026-08-19
Engine: PostgreSQL 18.3 (Homebrew)

## Scope and result

The 213 scripts already proven compatible with a read-only transaction were
executed separately in every connectable, non-template local database. Each
script ran inside its own read-only transaction with a 15-second statement
timeout, 1-second lock timeout, 30-second idle-transaction timeout, and 128-MB
temporary-file limit.

There were 1,278 database/script attempts: 1,221 passed and 57 were classified
as `PREREQUISITE_NOT_MET`. There were no new SQL defects. Template databases
were excluded because they are cloning templates rather than workload targets.

The remaining 61 scripts are writer-only setup, capture, maintenance, or lab
workflows. They were validated in the isolated audit database, not replayed in
every database, because doing so would create or change persistent objects and
would not be a safe certification technique. The destructive 5-GiB partition
lab remains deliberately unexecuted.

The 57 prerequisite outcomes are explainable and repeatable:

- Three in `pgbenchc_test`: capacity growth and scheduler reports require the
  `dba_metrics` repository/capture workflow.
- Twenty-seven in each transient workbench database: 24 require the
  per-database `pg_stat_statements` extension and three require `dba_metrics`
  repository objects.

Missing telemetry is not treated as a successful diagnosis or as a SQL defect.
It is an environment-readiness result.

## Controlled performance scenario

An eight-client, four-thread, 30-second built-in pgbench workload ran against
the 17-GB `pgbenchc_test` database:

- 685,123 transactions
- 0 failed transactions
- 22,843 TPS
- 0.350-ms average client latency

During the workload, live wait evidence detected `WALWrite`, `WalSync`,
`DataFileWrite`, and runnable sessions. Statement reports correctly attributed
the pgbench UPDATE workload, while existing controlled spill statements were
ranked by temporary blocks. This scenario validates signal routing and resource
attribution, not universal alert thresholds.

`pgstattuple_approx()` was also run against the 312-MB
`public.pgbench_accounts` table and returned sampled tuple, dead-tuple, and free
space evidence successfully.

The controlled results led to three accuracy corrections:

- The CPU report now says CPU *candidate*, exposes the statistics-reset window,
  and requires OS CPU plus wait-event corroboration. Shared-buffer hits are no
  longer labeled CPU work.
- The memory report now labels its percentage as temp-spill share rather than
  total memory pressure and exposes the statistics-reset window.
- The I/O report now distinguishes shared-buffer misses from guaranteed
  physical disk reads, reports `shared_blk_read_time`, the timing setting, and
  the cumulative statistics window.

## Accuracy contract

Successful execution proves compatibility, not diagnostic truth. The main
matrix therefore records an evidence basis, interpretation limit, and
validation level for every script:

- Catalog/configuration values are current facts, but not historical evidence.
- `pg_stat_activity`, locks, and progress views are point-in-time snapshots.
- `pg_stat_statements` and most `pg_stat_*` values are cumulative since reset;
  incident rates require two snapshots over the same interval.
- `n_live_tup`, `n_dead_tup`, `reltuples`, histograms, and MCVs are estimates
  whose accuracy depends on ANALYZE recency and statistics quality.
- AWS/Aurora SQL signals cannot replace CloudWatch, Performance Insights/
  Database Insights, Enhanced Monitoring, CloudTrail, or engine logs.
- Labels such as CPU-like, memory pressure, I/O candidate, or likely bloat are
  hypotheses for investigation, not proof of root cause.

No 10-TB or 50-TB performance claim is made from these local tests. Scale
confidence describes query work shape; production certification still requires
a representative clone or synthetic environment with matching object count,
partition count, concurrency, skew, storage, and telemetry retention.
