/*
Purpose: List currently running long queries and wait signals.
Area: Long Queries and Full Scans
Usage: Run during incidents; adjust threshold interval as needed.
*/
SELECT
    pid,
    datname AS database_name,
    usename AS user_name,
    application_name,
    client_addr,
    now() - query_start AS query_age,
    state,
    wait_event_type,
    wait_event,
    left(query, 400) AS query_snippet
FROM pg_stat_activity
WHERE state = 'active'
  AND query_start IS NOT NULL
  AND now() - query_start >= interval '1 minute'
ORDER BY query_age DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 pid | database_name | user_name | application_name | client_addr | query_age | state | wait_event_type | wait_event | query_snippet 
-----+---------------+-----------+------------------+-------------+-----------+-------+-----------------+------------+---------------
(0 rows)


SAMPLE_OUTPUT_END */
