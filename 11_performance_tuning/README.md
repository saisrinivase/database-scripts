# 11_performance_tuning

Query-level performance diagnostics for PostgreSQL DBAs.

Scripts in this area: `10`.

## PgAdmin-Friendly Top 10 Scripts

These scripts are plain SQL and do not use `psql` meta commands, so they can run from pgAdmin Query Tool, psql, DBeaver, DataGrip, or other SQL clients:

- `07_top_10_cpu_intensive_queries_pgadmin.sql`
- `08_top_10_temp_disk_spill_queries_pgadmin.sql`
- `09_top_10_memory_pressure_queries_pgadmin.sql`
- `10_active_top_10_runtime_pressure_pgadmin.sql`

## Notes

- Historical top-query scripts require `pg_stat_statements` in the current database.
- PostgreSQL core does not expose exact historical per-query CPU or allocated memory. The CPU report ranks database-time and logical-buffer churn candidates; the memory report ranks measured temp-file spill churn.
- `logical_buffer_churn` is cumulative PostgreSQL page access volume. It can indicate CPU-heavy scans, joins, repeated loops, or high call frequency, but it is not physical I/O and is not allocated RAM.
- `temp_spill_churn` is measured temporary-file traffic from memory-sensitive operators. Confirm the operator with `EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE)` before changing query-scoped or transaction-scoped `work_mem`.
- Always read `statistics_age`. Percentages are cumulative since `pg_stat_statements_info.stats_reset`, not automatically limited to the current incident.
- Use `10_active_top_10_runtime_pressure_pgadmin.sql` during a live incident even when `pg_stat_statements` is not installed.

## Incident Order

1. Run `10_active_top_10_runtime_pressure_pgadmin.sql` for current waits, blockers, and active SQL.
2. Run `07_top_10_cpu_intensive_queries_pgadmin.sql` for database-time and logical-buffer churn candidates.
3. Run `09_top_10_memory_pressure_queries_pgadmin.sql` for temp-spill churn.
4. Correlate the same time window with host CPU, AWS `CPUUtilization`/`DBLoadCPU`, and storage latency.
5. Validate the candidate with a representative execution plan before changing SQL, indexes, or memory settings.
