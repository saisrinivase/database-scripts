/*
Purpose: Flag very frequently called, short statements (common N+1 query symptom).
Area: Application Development and ORM Performance
Usage: Requires pg_stat_statements; validate in application traces.
*/
SELECT
    queryid,
    calls,
    mean_exec_time,
    total_exec_time,
    rows,
    CASE
        WHEN calls >= 50000 AND mean_exec_time < 5 THEN 'Strong N+1 candidate'
        WHEN calls >= 10000 AND mean_exec_time < 10 THEN 'Candidate'
        ELSE 'Observe'
    END AS recommendation,
    left(query, 240) AS query_snippet
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 200;
