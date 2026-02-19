/*
Purpose: List active and idle sessions with query age and wait details.
Area: Activity and Locks
Usage: Useful for live triage of load or stuck sessions.
*/
SELECT
    a.pid,
    a.usename AS user_name,
    a.application_name,
    a.client_addr,
    a.backend_start,
    a.xact_start,
    a.query_start,
    now() - a.query_start AS query_age,
    a.state,
    a.wait_event_type,
    a.wait_event,
    left(a.query, 400) AS query_snippet
FROM pg_stat_activity a
WHERE a.pid <> pg_backend_pid()
ORDER BY query_age DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | user_name | application_name | client_addr |         backend_start         | xact_start | query_start | query_age | state | wait_event_type |     wait_event      | query_snippet 
-- -----+-----------+------------------+-------------+-------------------------------+------------+-------------+-----------+-------+-----------------+---------------------+---------------
--  892 |           |                  |             | 2026-02-10 09:32:09.214793-05 |            |             |           |       | Activity        | AutovacuumMain      | 
--  893 | saiendla  |                  |             | 2026-02-10 09:32:09.216526-05 |            |             |           |       | Activity        | LogicalLauncherMain | 
--  885 |           |                  |             | 2026-02-10 09:32:09.197791-05 |            |             |           |       | Activity        | IoWorkerMain        | 
--  886 |           |                  |             | 2026-02-10 09:32:09.200077-05 |            |             |           |       | Activity        | IoWorkerMain        | 
--  887 |           |                  |             | 2026-02-10 09:32:09.201055-05 |            |             |           |       | Activity        | IoWorkerMain        | 
--  888 |           |                  |             | 2026-02-10 09:32:09.202493-05 |            |             |           |       | Activity        | CheckpointerMain    | 
--  889 |           |                  |             | 2026-02-10 09:32:09.20292-05  |            |             |           |       | Activity        | BgwriterMain        | 
--  891 |           |                  |             | 2026-02-10 09:32:09.21264-05  |            |             |           |       | Activity        | WalWriterMain       | 
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END

