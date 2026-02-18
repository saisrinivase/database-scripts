/*
Purpose: Inspect planner statistics profile for user-table columns.
Area: Planner and Statistics
Usage: Use for selectivity/skew analysis before tuning stats targets.
*/
SELECT
    schemaname AS schema_name,
    tablename AS table_name,
    attname AS column_name,
    null_frac,
    n_distinct,
    correlation,
    array_length(most_common_vals, 1) AS mcv_count,
    array_length(histogram_bounds, 1) AS histogram_bins
FROM pg_stats
WHERE schemaname !~ '^pg_'
  AND schemaname <> 'information_schema'
ORDER BY schemaname, tablename, attname;
