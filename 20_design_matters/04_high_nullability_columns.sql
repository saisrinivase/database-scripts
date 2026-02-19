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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | column_name | null_frac | n_distinct | correlation 
-- -------------+------------------+-------------+-----------+------------+-------------
--  public      | pgbench_branches | filler      |         1 |          0 |            
--  public      | pgbench_history  | filler      |         1 |          0 |            
--  public      | pgbench_tellers  | filler      |         1 |          0 |            
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
