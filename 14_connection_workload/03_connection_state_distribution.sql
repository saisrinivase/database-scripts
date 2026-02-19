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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 state  | session_count |      oldest_query_start       |      newest_query_start       | avg_query_age_seconds  
--------+---------------+-------------------------------+-------------------------------+------------------------
        |             8 |                               |                               |                       
 idle   |             3 | 2026-02-18 17:30:39.626331-05 | 2026-02-18 17:30:53.560003-05 |   746.3905846666666667
 active |             1 | 2026-02-18 17:43:13.120368-05 | 2026-02-18 17:43:13.120368-05 | 0.00000000000000000000
(3 rows)


SAMPLE_OUTPUT_END */
