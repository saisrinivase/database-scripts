# 44_live_test_monitoring

Live PostgreSQL CPU-pressure reproduction and process identification for pgAdmin and command-line use.

## Local Validation Workflow

Use only a local or disposable test database for the workload generator.

1. Open two pgAdmin Query Tool tabs connected to the same database.
2. Run `01_local_cpu_pressure_lab_generator.sql` in tab 1. It runs for 30 seconds by default.
3. While tab 1 is busy, run `02_identify_active_cpu_processes_pgadmin.sql` in tab 2.
4. Match `backend_pid`, `application_name`, `query_id`, and `complete_query_text`.
5. After the workload completes, use `11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql` for cumulative query evidence.

For this temporary lab function, enable the CPU report's noise override and filter before running step 5:

```sql
SELECT set_config('pgdiag.query_filter', 'generate_cpu_pressure', false);
SELECT set_config('pgdiag.include_noise', 'on', false);
```

The expected live result identifies `pgdiag_cpu_pressure_lab` as a P1 process with no reported wait event and displays the complete `SELECT` statement invoking the temporary CPU function.

Observed during local validation:

```text
priority  backend_pid  application_name           runtime_s  wait_type  query_id
P1        93836        pgdiag_cpu_pressure_lab    5.801      NULL       849216942406289872
```

The completed workload performed `52,376,438` bounded loop iterations in 20 seconds. The iteration count is machine-dependent and is not a benchmark score.

The cumulative report then returned the same query ID with `20.00` seconds of database time, `904 kB` cumulative page access, and `0 bytes` temporary spill. Database time is elapsed execution time, not exact host CPU time. The lab query ID can change between sessions because it references a newly created temporary function; normal application query IDs are expected to remain stable when parsed identically against the same objects.

## RDS And Aurora Usage

Do not run the pressure generator on production or shared cloud databases. During a real CPU incident, run only `02_identify_active_cpu_processes_pgadmin.sql` from pgAdmin. It uses core `pg_stat_activity` fields available on PostgreSQL 15+ and does not require an extension or operating-system access.

For sessions owned by other users, grant an approved monitoring identity `pg_monitor` or `pg_read_all_stats`, or use the managed-service equivalent. Correlate the returned PID and timestamp with CloudWatch `CPUUtilization`, Performance Insights or Database Insights `DBLoadCPU`, and operating-system process CPU where available.

## Accuracy Boundary

- `backend_pid` is the PostgreSQL server process identifier. On RDS and Aurora it identifies the database backend even though host process tools are unavailable.
- `state = 'active'` with no `wait_event_type` means the process is executing or waiting for CPU scheduling. It is a strong live candidate, not exact proof or a CPU percentage.
- A reported wait event means elapsed query time includes waiting and should be routed to that subsystem first.
- Exact attribution requires timestamp correlation with host or AWS CPU telemetry. Query-plan validation is still required before changing SQL, indexes, or parameters.
- The diagnostic returns complete normalized query text without truncating it. PostgreSQL can only expose text retained within `track_activity_query_size`.
