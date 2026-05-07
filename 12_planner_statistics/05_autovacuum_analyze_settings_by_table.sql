/*
PostgreSQL DBA Script: Autovacuum Analyze Settings By Table
Purpose: Show table-level reloptions that override analyze/autovacuum behavior.
Area: Planner and Statistics
Usage: Review inconsistent per-table settings across critical schemas.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.reloptions
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 'p')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND c.reloptions IS NOT NULL
ORDER BY n.nspname, c.relname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    |    reloptions    
-- -------------+------------------+------------------
--  public      | pgbench_accounts | {fillfactor=100}
--  public      | pgbench_branches | {fillfactor=100}
--  public      | pgbench_tellers  | {fillfactor=100}
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
