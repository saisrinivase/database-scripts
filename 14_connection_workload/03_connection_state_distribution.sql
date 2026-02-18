/*
Purpose: Summarize session states and average age per state.
Area: Connection and Workload
Usage: Detect excessive idle or long-running active workloads.
*/
SELECT
    state,
    count(*) AS session_count,
    min(query_start) AS oldest_query_start,
    max(query_start) AS newest_query_start,
    avg(extract(epoch FROM (now() - query_start))) FILTER (WHERE query_start IS NOT NULL) AS avg_query_age_seconds
FROM pg_stat_activity
GROUP BY state
ORDER BY session_count DESC;
