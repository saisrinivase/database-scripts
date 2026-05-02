# 11_performance_tuning

Top statements, latency, temp tables, I/O-heavy statements, variables, and routines.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 11_performance_tuning/<script>.sql`.

## Scripts

- `01_top_queries_by_total_exec_time.sql`
- `02_top_queries_by_mean_exec_time.sql`
- `03_temp_file_heavy_queries.sql`
- `04_io_bound_query_candidates.sql`
- `05_performance_related_settings.sql`
- `06_function_hotspots.sql`
