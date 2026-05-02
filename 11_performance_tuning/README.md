# 11_performance_tuning

Top SQL, temp-heavy SQL, I/O-heavy SQL, parameter tuning, and PL/SQL hotspots.

Scripts in this area: `15`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @11_performance_tuning/<script>.sql`.

## Scripts

- `01_top_queries_by_total_exec_time.sql`
- `02_top_queries_by_mean_exec_time.sql`
- `03_temp_file_heavy_queries.sql`
- `04_io_bound_query_candidates.sql`
- `05_performance_related_settings.sql`
- `06_function_hotspots.sql`
- `07_awr_top_sql_by_elapsed_time.sql`
- `08_awr_top_sql_by_cpu_time.sql`
- `09_awr_top_sql_by_io_wait.sql`
- `10_ash_wait_event_trend.sql`
- `11_ash_top_sql_last_hour.sql`
- `12_sql_plan_change_watchlist.sql`
- `13_bind_sensitive_sql.sql`
- `14_sql_monitor_active_operations.sql`
- `15_top_sql_by_parse_calls.sql`
