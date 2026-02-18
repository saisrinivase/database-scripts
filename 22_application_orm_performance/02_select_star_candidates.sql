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
