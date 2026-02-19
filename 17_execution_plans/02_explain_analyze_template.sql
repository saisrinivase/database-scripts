/*
Purpose: Template to read and understand execution plans for problematic queries.
Area: Execution Plans
Usage: Replace `SELECT 1` with target SQL and run in a lower environment first.
*/
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS, FORMAT TEXT)
SELECT 1;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

                                      QUERY PLAN                                       
---------------------------------------------------------------------------------------
 Result  (cost=0.00..0.01 rows=1 width=4) (actual time=0.001..0.003 rows=1.00 loops=1)
   Output: 1
 Query Identifier: -3688696628780506391
 Planning:
   Buffers: shared hit=3
 Planning Time: 0.127 ms
 Execution Time: 0.046 ms
(7 rows)


SAMPLE_OUTPUT_END */
