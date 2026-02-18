/*
Purpose: Detect chatty query patterns with many calls and tiny average row returns.
Area: Application Development and ORM Performance
Usage: Useful for API batching and data loader strategy tuning.
*/
SELECT
    queryid,
    calls,
    rows,
    CASE WHEN calls = 0 THEN NULL ELSE round(rows::numeric / calls, 4) END AS avg_rows_per_call,
    mean_exec_time,
    total_exec_time,
    left(query, 260) AS query_snippet
FROM pg_stat_statements
WHERE calls >= 5000
ORDER BY avg_rows_per_call ASC NULLS LAST, calls DESC
LIMIT 200;
