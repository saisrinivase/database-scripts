/*
PostgreSQL DBA Script: Active Top 10 Runtime Pressure PgAdmin
Purpose: Show the top currently running sessions by age with wait, lock, transaction, and query text context.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client during a live slowdown.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. This is the live companion to pg_stat_statements historical top-query scripts.
*/
SELECT
    a.pid,
    a.datname AS database_name,
    a.usename AS user_name,
    coalesce(nullif(a.application_name, ''), '(none)') AS application_name,
    a.client_addr,
    a.backend_type,
    a.state,
    a.wait_event_type,
    a.wait_event,
    now() - a.query_start AS query_age,
    now() - a.xact_start AS transaction_age,
    now() - a.backend_start AS backend_age,
    cardinality(pg_blocking_pids(a.pid)) AS blocking_session_count,
    pg_blocking_pids(a.pid) AS blocking_pids,
    CASE
        WHEN cardinality(pg_blocking_pids(a.pid)) > 0 THEN 'Blocked by another session; inspect blocker chain first.'
        WHEN a.wait_event_type = 'Lock' THEN 'Waiting on lock; check blocker and transaction scope.'
        WHEN a.wait_event_type = 'IO' THEN 'Waiting on IO; compare with IO and temp spill scripts.'
        WHEN a.wait_event_type = 'Client' THEN 'Waiting on client; check app/result consumption/network behavior.'
        WHEN a.state = 'active' AND a.wait_event_type IS NULL THEN 'Running without wait event; possible CPU-bound execution.'
        ELSE 'Review query age, transaction age, and wait event.'
    END AS sme_diagnosis,
    left(regexp_replace(a.query, '\s+', ' ', 'g'), 260) AS query_sample
FROM pg_stat_activity a
WHERE a.pid <> pg_backend_pid()
  AND a.state IS DISTINCT FROM 'idle'
ORDER BY
    CASE WHEN cardinality(pg_blocking_pids(a.pid)) > 0 THEN 0 ELSE 1 END,
    a.query_start NULLS LAST,
    a.xact_start NULLS LAST
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- pid  | database_name | user_name | state  | wait_event_type | query_age | blocking_session_count | sme_diagnosis
-- -----+---------------+-----------+--------+-----------------+-----------+------------------------+-------------------------------------------
-- 8123 | appdb         | app_user  | active | Lock            | 00:03:10  |                      1 | Blocked by another session...
-- SAMPLE_OUTPUT_END
