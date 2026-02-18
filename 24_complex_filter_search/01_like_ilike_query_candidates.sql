/*
Purpose: Find LIKE/ILIKE-heavy statements that may need trigram/full-text strategy.
Area: Complex Filtering and Search
Usage: Requires pg_stat_statements.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    shared_blks_read,
    temp_blks_written,
    left(query, 320) AS query_snippet
FROM pg_stat_statements
WHERE query ILIKE '% like %'
   OR query ILIKE '% ilike %'
ORDER BY total_exec_time DESC
LIMIT 200;
