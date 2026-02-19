/*
Purpose: Identify statements that use SELECT * and may fetch unnecessary columns.
Area: Application Development and ORM Performance
Usage: Requires pg_stat_statements; review ORM projections.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    rows,
    left(query, 300) AS query_snippet
FROM pg_stat_statements
WHERE query ILIKE 'select *%'
ORDER BY total_exec_time DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        | calls |   total_exec_time    |    mean_exec_time     | rows |                                                                                                                                                query_snippet                                                                                                                                                 
-- ----------------------+-------+----------------------+-----------------------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  -7038069733341480218 |     1 |   17.545082999999998 |    17.545082999999998 | 2185 | SELECT * FROM (SELECT current_database() AS current_database, n.nspname,c.relname,a.attname,a.atttypid,a.attnotnull  OR (t.typtype = $1 AND t.typnotnull) AS attnotnull,a.atttypmod,a.attlen,t.typtypmod,row_number() OVER (PARTITION BY a.attrelid ORDER BY a.attnum) AS attnum, nullif(a.attidentity, $2) 
--   6967984576543786987 |  1310 |   2.2980440000000093 | 0.0017542320610687042 | 1940 | SELECT * FROM pg_catalog.unnest($1) WITH ORDINALITY
--    515528283152159450 |     2 | 0.018583999999999996 |  0.009291999999999998 |    2 | SELECT * FROM pg_catalog.pg_rewrite WHERE ev_class = $1 AND rulename = $2
--   7922352538918149262 |     1 |             0.006083 |              0.006083 |    0 | SELECT *                                                                                                                                                                                                                                                                                                    +
--                       |       |                      |                       |      | FROM pg_stat_wal_receiver
-- (4 rows)
-- 
-- SAMPLE_OUTPUT_END
