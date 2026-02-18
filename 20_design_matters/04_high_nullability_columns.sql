/*
Purpose: Identify columns with high null fraction that may indicate schema redesign opportunities.
Area: Design Matters
Usage: Review with domain model and query usage before schema changes.
*/
SELECT
    schemaname AS schema_name,
    tablename AS table_name,
    attname AS column_name,
    null_frac,
    n_distinct,
    correlation
FROM pg_stats
WHERE schemaname !~ '^pg_'
  AND schemaname <> 'information_schema'
  AND null_frac >= 0.80
ORDER BY null_frac DESC, schemaname, tablename, attname;
