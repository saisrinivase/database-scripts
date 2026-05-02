# 11_performance_tuning

Top SQL, temp-heavy SQL, I/O-heavy SQL, parameter tuning, and PL/SQL hotspots.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @11_performance_tuning/<script>.sql`.

## Scripts

- `01_top_queries_by_total_exec_time.sql`
- `02_top_queries_by_mean_exec_time.sql`
- `03_temp_file_heavy_queries.sql`
- `04_io_bound_query_candidates.sql`
- `05_performance_related_settings.sql`
- `06_function_hotspots.sql`
