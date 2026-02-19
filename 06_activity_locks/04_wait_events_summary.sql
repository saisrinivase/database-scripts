/*
Purpose: Summarize wait events across sessions to spot dominant bottlenecks.
Area: Activity and Locks
Usage: Run repeatedly to compare shifting wait profiles.
*/
SELECT
    coalesce(wait_event_type, 'CPU/None') AS wait_event_type,
    coalesce(wait_event, 'CPU/None') AS wait_event,
    state,
    count(*) AS session_count
FROM pg_stat_activity
GROUP BY coalesce(wait_event_type, 'CPU/None'), coalesce(wait_event, 'CPU/None'), state
ORDER BY session_count DESC, wait_event_type, wait_event;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 wait_event_type |      wait_event      | state  | session_count 
-----------------+----------------------+--------+---------------
 Activity        | IoWorkerMain         |        |             3
 Client          | ClientRead           | idle   |             3
 Activity        | AutovacuumMain       |        |             1
 Activity        | BgwriterHibernate    |        |             1
 Activity        | LogicalLauncherMain  |        |             1
 Activity        | WalWriterMain        |        |             1
 CPU/None        | CPU/None             | active |             1
 Timeout         | CheckpointWriteDelay |        |             1
(8 rows)


SAMPLE_OUTPUT_END */
