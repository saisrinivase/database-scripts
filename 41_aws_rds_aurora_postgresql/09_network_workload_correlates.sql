/*
PostgreSQL DBA Script: AWS Network Workload Correlates
Purpose: Deep-dive NetworkReceiveThroughput, NetworkTransmitThroughput, NetworkThroughput, and Aurora storage-network alarms with SQL workload evidence.
Area: AWS RDS and Aurora PostgreSQL
Usage: Use CloudWatch for exact bytes per second and this script to identify connection, row-volume, COPY, replication, and application contributors.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only except for a pg_temp function. SQL cannot read managed host NIC counters.
*/
SELECT
    datname,
    usename,
    application_name,
    client_addr,
    backend_type,
    state,
    count(*) AS connections,
    count(*) FILTER (WHERE state = 'active') AS active_connections,
    count(*) FILTER (WHERE wait_event_type = 'Client') AS client_waits,
    max(clock_timestamp() - query_start) FILTER (WHERE state = 'active') AS longest_active_query
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
GROUP BY datname, usename, application_name, client_addr, backend_type, state
ORDER BY connections DESC, active_connections DESC;

SELECT
    datname,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,
    blks_read,
    blks_hit,
    stats_reset,
    'Use two snapshots to calculate tuple and block rates over the CloudWatch network period.' AS rate_instruction
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY tup_returned + tup_fetched DESC;

SELECT
    p.pid,
    p.datid,
    p.relid,
    p.command,
    p.type,
    p.bytes_processed,
    p.bytes_total,
    p.tuples_processed,
    p.tuples_excluded,
    a.usename,
    a.application_name,
    a.client_addr,
    regexp_replace(a.query, '\s+', ' ', 'g') AS complete_query_text
FROM pg_stat_progress_copy p
LEFT JOIN pg_stat_activity a ON a.pid = p.pid
ORDER BY p.bytes_processed DESC;

SELECT
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS outstanding_replication_bytes,
    reply_time
FROM pg_stat_replication
ORDER BY outstanding_replication_bytes DESC NULLS LAST;

CREATE OR REPLACE FUNCTION pg_temp.aws_network_top_statements()
RETURNS TABLE (
    queryid bigint,
    calls bigint,
    rows_returned bigint,
    rows_per_call numeric,
    total_exec_ms numeric,
    shared_read_bytes numeric,
    wal_bytes numeric,
    complete_query_text text,
    network_direction_hint text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_statements') IS NULL
       AND to_regclass('public.pg_stat_statements') IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY EXECUTE $query$
        SELECT
            s.queryid,
            s.calls,
            s.rows,
            round(s.rows::numeric / NULLIF(s.calls, 0), 2),
            round(s.total_exec_time::numeric, 2),
            s.shared_blks_read::numeric * current_setting('block_size')::numeric,
            coalesce(s.wal_bytes, 0)::numeric,
            regexp_replace(s.query, '\s+', ' ', 'g'),
            CASE
                WHEN lower(ltrim(s.query)) LIKE 'select%' AND s.rows > 1000000 THEN 'TRANSMIT_CANDIDATE_LARGE_RESULT_VOLUME'
                WHEN lower(ltrim(s.query)) ~ '^(insert|update|delete|merge|copy)' THEN 'RECEIVE_OR_STORAGE_WRITE_CANDIDATE'
                WHEN s.calls > 100000 THEN 'CHATTER_CANDIDATE_HIGH_CALL_RATE'
                ELSE 'CORRELATE_WITH_APPLICATION_AND_TIME_WINDOW'
            END
        FROM pg_stat_statements s
        ORDER BY s.rows DESC, s.calls DESC
        LIMIT 50
    $query$;
END;
$$;

SELECT *
FROM pg_temp.aws_network_top_statements();

SELECT *
FROM (VALUES
    ('NetworkReceiveThroughput', 'AWS_ONLY_WITH_SQL_CORRELATION', 'Includes database and service traffic; SQL cannot measure NIC bytes.'),
    ('NetworkTransmitThroughput', 'AWS_ONLY_WITH_SQL_CORRELATION', 'Use high-row SELECT, COPY, and replication evidence as contributors, not byte equivalents.'),
    ('NetworkThroughput', 'AWS_ONLY_WITH_SQL_CORRELATION', 'Aurora client network total excludes storage-subsystem traffic.'),
    ('StorageNetworkReceiveThroughput', 'AWS_ONLY', 'Aurora storage-network bytes are service-layer metrics. Correlate with physical reads.'),
    ('StorageNetworkTransmitThroughput', 'AWS_ONLY', 'Aurora storage-network bytes are service-layer metrics. Correlate with dirty buffers and WAL.'),
    ('StorageNetworkThroughput', 'AWS_ONLY', 'Aurora storage-network total is not exposed by PostgreSQL SQL.')
) AS aws_network_boundary(metric_name, visibility, interpretation);

-- SAMPLE_OUTPUT_BEGIN
-- application_name | client_addr | connections | active_connections | client_waits
-- queryid | rows_returned | rows_per_call | complete_query_text | network_direction_hint
-- SAMPLE_OUTPUT_END
