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
- PostgreSQL core does not expose exact historical per-query CPU or allocated memory. The CPU report ranks database-time and page-access candidates; the memory report ranks measured temporary-file spills.
- `cumulative_page_access` is `(shared_blks_hit + shared_blks_read) * block_size` since the statistics reset. Repeated access to the same page is counted repeatedly, so 48 GB means the equivalent of 48 GB of cumulative page touches. It is not 48 GB of allocated RAM or physical disk I/O. A high value can identify CPU-heavy scans, joins, nested loops, or high call frequency.
- `cumulative_temp_spill` is measured temporary-file traffic from memory-sensitive operators. Confirm the operator with `EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE)` before changing query-scoped or transaction-scoped `work_mem`.
- Always read `statistics_age`. Percentages are cumulative since `pg_stat_statements_info.stats_reset`, not automatically limited to the current incident.
- Use `10_active_top_10_runtime_pressure_pgadmin.sql` during a live incident even when `pg_stat_statements` is not installed.

## Incident Order

1. Run `10_active_top_10_runtime_pressure_pgadmin.sql` for current waits, blockers, and active SQL.
2. Run `07_top_10_cpu_intensive_queries_pgadmin.sql` for database-time and repeated page-access candidates.
3. Run `09_top_10_memory_pressure_queries_pgadmin.sql` for temporary-file spills.
4. Correlate the same time window with host CPU, AWS `CPUUtilization`/`DBLoadCPU`, and storage latency.
5. Validate the candidate with a representative execution plan before changing SQL, indexes, or memory settings.
