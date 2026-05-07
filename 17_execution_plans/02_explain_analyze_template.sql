/*
PostgreSQL DBA Script: Explain Analyze Template
Purpose: Template to read and understand execution plans for problematic queries.
Area: Execution Plans
Usage: Replace `SELECT 1` with target SQL and run in a lower environment first.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS, FORMAT TEXT)
SELECT 1;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--                                       QUERY PLAN                                       
-- ---------------------------------------------------------------------------------------
--  Result  (cost=0.00..0.01 rows=1 width=4) (actual time=0.001..0.001 rows=1.00 loops=1)
--    Output: 1
--  Query Identifier: -3688696628780506391
--  Planning:
--    Buffers: shared hit=3
--  Planning Time: 0.057 ms
--  Execution Time: 0.033 ms
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END
