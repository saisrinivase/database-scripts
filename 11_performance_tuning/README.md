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
- PostgreSQL core does not expose exact historical per-query CPU or memory usage. CPU and memory scripts use SME-safe proxies from execution time, temp blocks, rows per call, block footprint, and runtime variance.
- Use `10_active_top_10_runtime_pressure_pgadmin.sql` during a live incident even when `pg_stat_statements` is not installed.
