/*
PostgreSQL DBA Script: AWS Connections Commits Deadlocks
Purpose: Deep-dive DatabaseConnections, IamDbAuthConnectionRequests, CommitLatency, CommitThroughput, Deadlocks, and EngineUptime.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run during a connection, commit, deadlock, or restart alarm and compare counter deltas with the CloudWatch period.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. IAM request counts and exact Aurora commit latency remain AWS-only metrics.
*/
WITH settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
connections AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE backend_type = 'client backend')::numeric AS client_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_transaction,
        count(*) FILTER (WHERE wait_event_type = 'Lock')::numeric AS lock_waiters
    FROM pg_stat_activity
),
transactions AS (
    SELECT
        coalesce(sum(xact_commit), 0)::numeric AS commits,
        coalesce(sum(xact_rollback), 0)::numeric AS rollbacks,
        coalesce(sum(deadlocks), 0)::numeric AS deadlocks,
        min(stats_reset) AS oldest_stats_reset
    FROM pg_stat_database
    WHERE datname IS NOT NULL
)
SELECT
    'connections_transactions_uptime' AS report_section,
    clock_timestamp() - pg_postmaster_start_time() AS engine_uptime,
    c.total_connections,
    c.client_connections,
    c.active_connections,
    c.idle_in_transaction,
    c.lock_waiters,
    s.max_connections,
    round(100.0 * c.total_connections / NULLIF(s.max_connections, 0), 2) AS connection_utilization_pct,
    t.commits,
    t.rollbacks,
    round(100.0 * t.rollbacks / NULLIF(t.commits + t.rollbacks, 0), 2) AS rollback_pct,
    t.deadlocks,
    t.oldest_stats_reset,
    CASE
        WHEN c.total_connections >= s.max_connections * 0.90 THEN 'CRITICAL: connection usage is at least 90 percent.'
        WHEN c.idle_in_transaction > 0 THEN 'REVIEW: idle transactions consume connections and can hold locks/snapshots.'
        WHEN c.lock_waiters > 0 THEN 'REVIEW: lock waits can increase commit latency.'
        WHEN t.deadlocks > 0 THEN 'Historical deadlocks exist; calculate the alarm-window delta and inspect logs.'
        ELSE 'No dominant connection/transaction warning in this snapshot.'
    END AS diagnosis
FROM settings s
CROSS JOIN connections c
CROSS JOIN transactions t;

SELECT
    a.pid AS blocked_pid,
    a.usename AS blocked_user,
    a.datname,
    a.application_name,
    clock_timestamp() - a.query_start AS blocked_duration,
    a.wait_event,
    pg_blocking_pids(a.pid) AS blocking_pids,
    regexp_replace(a.query, '\s+', ' ', 'g') AS complete_blocked_query,
    'Find every blocker, then review transaction ordering and application retry behavior.' AS recommended_action
FROM pg_stat_activity a
WHERE cardinality(pg_blocking_pids(a.pid)) > 0
ORDER BY blocked_duration DESC;

SELECT
    backend_type,
    wait_event_type,
    wait_event,
    count(*) AS waiting_backends,
    max(clock_timestamp() - query_start) AS longest_query_age,
    CASE
        WHEN wait_event IN ('WALSync', 'WALWrite') THEN 'Local WAL durability can contribute to commit latency.'
        WHEN wait_event ILIKE 'SyncRep%' THEN 'Synchronous replication acknowledgement can contribute to commit latency.'
        WHEN wait_event_type = 'Lock' THEN 'Lock contention delays transaction completion.'
        WHEN wait_event_type = 'IO' THEN 'Storage I/O can delay transaction completion.'
        ELSE 'Correlate this wait with the same CloudWatch window.'
    END AS commit_latency_evidence
FROM pg_stat_activity
WHERE wait_event_type IS NOT NULL
GROUP BY backend_type, wait_event_type, wait_event
ORDER BY waiting_backends DESC, wait_event;

SELECT
    datname,
    xact_commit,
    xact_rollback,
    deadlocks,
    conflicts,
    stats_reset,
    'Take a second snapshot after the CloudWatch period; divide counter deltas by elapsed seconds for throughput.' AS rate_instruction
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY deadlocks DESC, xact_commit DESC;

-- SAMPLE_OUTPUT_BEGIN
-- engine_uptime | total_connections | connection_utilization_pct | commits | deadlocks | diagnosis
-- blocked_pid | blocking_pids | complete_blocked_query | recommended_action
-- SAMPLE_OUTPUT_END
