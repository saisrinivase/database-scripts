/*
PostgreSQL DBA Script: Wait Events Summary
Purpose: Summarize wait events across sessions to spot dominant bottlenecks.
Area: Activity and Locks
Usage: Run repeatedly to compare shifting wait profiles.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    coalesce(wait_event_type, 'CPU/None') AS wait_event_type,
    coalesce(wait_event, 'CPU/None') AS wait_event,
    state,
    count(*) AS session_count
FROM pg_stat_activity
GROUP BY coalesce(wait_event_type, 'CPU/None'), coalesce(wait_event, 'CPU/None'), state
ORDER BY session_count DESC, wait_event_type, wait_event;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  wait_event_type |     wait_event      | state  | session_count 
-- -----------------+---------------------+--------+---------------
--  Activity        | IoWorkerMain        |        |             3
--  Activity        | AutovacuumMain      |        |             1
--  Activity        | BgwriterMain        |        |             1
--  Activity        | CheckpointerMain    |        |             1
--  Activity        | LogicalLauncherMain |        |             1
--  Activity        | WalWriterMain       |        |             1
--  CPU/None        | CPU/None            | active |             1
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END
