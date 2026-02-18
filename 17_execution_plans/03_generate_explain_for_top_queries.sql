/*
Purpose: Generate EXPLAIN command text for top queries from pg_stat_statements.
Area: Execution Plans
Usage: Requires pg_stat_statements; execute generated commands one-by-one with care.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    left(query, 180) AS query_snippet,
    format('/* queryid=%s */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) %s;', queryid, query) AS explain_sql
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 50;
