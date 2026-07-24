/*
PostgreSQL DBA Script: AWS Database Insights DBLoad Deep Dive
Purpose: Diagnose DBLoad, DBLoadCPU, DBLoadNonCPU, and DBLoadRelativeToNumVCPUs using live PostgreSQL session, wait, SQL, user, and application evidence.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run during the Database Insights spike and compare with the identical DB instance and time window.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. AWS DBLoad is sampled average active sessions; this SQL is an instantaneous session snapshot and cannot reproduce historical AAS or AWS vCPU count.
*/
WITH active_load AS (
    SELECT
        count(*) FILTER (
            WHERE backend_type = 'client backend'
              AND state = 'active'
              AND pid <> pg_backend_pid()
        )::numeric AS active_sessions,
        count(*) FILTER (
            WHERE backend_type = 'client backend'
              AND state = 'active'
              AND wait_event_type IS NULL
              AND pid <> pg_backend_pid()
        )::numeric AS cpu_load_proxy,
        count(*) FILTER (
            WHERE backend_type = 'client backend'
              AND state = 'active'
              AND wait_event_type IS NOT NULL
              AND pid <> pg_backend_pid()
        )::numeric AS non_cpu_load_proxy
    FROM pg_stat_activity
)
SELECT
    active_sessions AS instantaneous_dbload_proxy,
    cpu_load_proxy AS instantaneous_dbloadcpu_proxy,
    non_cpu_load_proxy AS instantaneous_dbloadnoncpu_proxy,
    round(100.0 * cpu_load_proxy / NULLIF(active_sessions, 0), 2) AS cpu_share_pct,
    round(100.0 * non_cpu_load_proxy / NULLIF(active_sessions, 0), 2) AS non_cpu_share_pct,
    CASE
        WHEN active_sessions = 0 THEN 'NO_ACTIVE_CLIENT_LOAD_IN_THIS_SNAPSHOT'
        WHEN cpu_load_proxy > non_cpu_load_proxy THEN 'CPU_OR_CPU_SCHEDULING_DOMINATES'
        WHEN non_cpu_load_proxy > cpu_load_proxy THEN 'WAIT_EVENTS_DOMINATE'
        ELSE 'MIXED_OR_LOW_LOAD'
    END AS dominant_load_class,
    'Use AWS DBLoadRelativeToNumVCPUs for the exact AAS/vCPU ratio.' AS aws_boundary
FROM active_load;

WITH load_sessions AS (
    SELECT
        CASE
            WHEN wait_event_type IS NULL THEN 'CPU'
            ELSE coalesce(wait_event_type, 'Unknown')
        END AS load_dimension,
        wait_event,
        pid,
        clock_timestamp() - query_start AS query_age,
        query
    FROM pg_stat_activity
    WHERE backend_type = 'client backend'
      AND state = 'active'
      AND pid <> pg_backend_pid()
)
SELECT
    load_dimension,
    wait_event,
    count(*) AS active_sessions,
    round(100.0 * count(*) / NULLIF(sum(count(*)) OVER (), 0), 2) AS current_load_pct,
    max(query_age) AS longest_query_age,
    string_agg(DISTINCT regexp_replace(query, '\s+', ' ', 'g'), E'\n') AS complete_query_texts,
    CASE
        WHEN load_dimension = 'CPU' THEN 'Rank SQL and inspect plans, row estimates, scan volume, functions, JIT, and parallelism.'
        WHEN load_dimension = 'IO' THEN 'Correlate with queue depth, latency, cache misses, temp spills, WAL, and checkpoints.'
        WHEN load_dimension = 'Lock' THEN 'Find blockers and transaction ownership before changing timeouts.'
        WHEN load_dimension IN ('LWLock', 'BufferPin') THEN 'Inspect the exact wait event and shared-resource contention.'
        ELSE 'Use the wait event as the next subsystem route.'
    END AS next_action
FROM load_sessions
GROUP BY load_dimension, wait_event
ORDER BY active_sessions DESC, longest_query_age DESC NULLS LAST;

SELECT
    coalesce(usename, '<background>') AS user_name,
    coalesce(application_name, '<unset>') AS application_name,
    coalesce(client_addr::text, '<local>') AS client_host,
    count(*) AS active_sessions,
    count(*) FILTER (WHERE wait_event_type IS NULL) AS cpu_candidates,
    count(*) FILTER (WHERE wait_event_type IS NOT NULL) AS waiting_sessions,
    round(100.0 * count(*) / NULLIF(sum(count(*)) OVER (), 0), 2) AS current_load_pct
FROM pg_stat_activity
WHERE state = 'active'
  AND backend_type = 'client backend'
  AND pid <> pg_backend_pid()
GROUP BY usename, application_name, client_addr
ORDER BY active_sessions DESC, user_name, application_name;

SELECT *
FROM (VALUES
    ('DBLoad', 'Average', 'Average active sessions. Compare total AAS with vCPU and the normal workload baseline.'),
    ('DBLoadCPU', 'Average', 'AAS classified as CPU. Active sessions with no wait event are the live PostgreSQL proxy.'),
    ('DBLoadNonCPU', 'Average', 'AAS classified in non-CPU waits. Break down by wait event type and event.'),
    ('DBLoadRelativeToNumVCPUs', 'Average/Maximum', 'AWS-computed DBLoad divided by vCPU count. Values above 1 indicate more active demand than vCPUs, but wait composition still matters.')
) AS m(metric_name, recommended_statistic, interpretation);

-- SAMPLE_OUTPUT_BEGIN
-- instantaneous_dbload_proxy | instantaneous_dbloadcpu_proxy | instantaneous_dbloadnoncpu_proxy | cpu_share_pct | non_cpu_share_pct | dominant_load_class
-- load_dimension | wait_event | active_sessions | current_load_pct | longest_query_age | complete_query_texts | next_action
-- SAMPLE_OUTPUT_END
