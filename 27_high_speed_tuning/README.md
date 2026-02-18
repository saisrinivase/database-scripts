# High Speed Tuning Quick Run Order

Purpose: Fast path to tune PostgreSQL, detect bottlenecks, and identify missing indexes.

## Run Order

1. `01_bottleneck_overview_dashboard.sql`
2. `02_waits_and_blocking_details.sql`
3. `06_query_tuning_action_queue.sql`
4. `03_missing_index_candidates_from_scan_pressure.sql`
5. `04_missing_fk_index_candidates.sql`
6. `05_parameter_tuning_advisor.sql`

## Notes

- `06_query_tuning_action_queue.sql` and some earlier scripts require `pg_stat_statements`.
- Index candidate scripts are advisory; validate with `EXPLAIN (ANALYZE, BUFFERS)` before creating indexes.
- Apply parameter changes in staging first, then roll out with measurement.
