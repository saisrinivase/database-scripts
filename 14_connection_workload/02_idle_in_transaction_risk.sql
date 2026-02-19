/*
Purpose: List idle-in-transaction sessions that can cause bloat and lock retention.
Area: Connection and Workload
Usage: Investigate application transaction handling for recurring offenders.
*/
SELECT
    pid,
    datname AS database_name,
    usename AS user_name,
    application_name,
    client_addr,
    xact_start,
    state_change,
    now() - xact_start AS xact_age,
    now() - state_change AS idle_in_txn_age,
    wait_event_type,
    wait_event,
    left(query, 400) AS query_snippet
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY xact_age DESC NULLS LAST;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 pid | database_name | user_name | application_name | client_addr | xact_start | state_change | xact_age | idle_in_txn_age | wait_event_type | wait_event | query_snippet 
-----+---------------+-----------+------------------+-------------+------------+--------------+----------+-----------------+-----------------+------------+---------------
(0 rows)


SAMPLE_OUTPUT_END */
