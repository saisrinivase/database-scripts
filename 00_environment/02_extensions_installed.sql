/*
PostgreSQL DBA Script: Extensions Installed
Purpose: List installed extensions and their schema/version.
Area: Environment / Internals
Usage: Run in any database.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    e.extname AS extension_name,
    e.extversion AS extension_version,
    n.nspname AS extension_schema,
    pg_get_userbyid(e.extowner) AS extension_owner
FROM pg_extension e
JOIN pg_namespace n
    ON n.oid = e.extnamespace
ORDER BY e.extname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    extension_name   | extension_version | extension_schema | extension_owner 
-- --------------------+-------------------+------------------+-----------------
--  pg_stat_statements | 1.12              | public           | saiendla
--  plpgsql            | 1.0               | pg_catalog       | saiendla
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
