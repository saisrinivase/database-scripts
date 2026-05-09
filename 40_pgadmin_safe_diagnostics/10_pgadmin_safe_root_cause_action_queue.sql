/*
Purpose: pgAdmin-safe root cause action queue for PostgreSQL incidents.
Scope: Produces prioritized findings for locks, long transactions, XID age, checkpoint/WAL pressure, temp spills, cache pressure, replication, archiving, and pg_stat_statements readiness.
pgAdmin: Safe to run in Query Tool. Uses a temporary helper function only.
Sample output:
 priority | symptom              | evidence             | next_action
----------+----------------------+----------------------+--------------------------------
 P1       | lock waits detected  | waiters=2            | Identify blocker PID and SQL.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_root_cause_action_queue()
RETURNS TABLE (
    priority text,
    symptom text,
    evidence text,
    next_action text,
    source_view text
)
LANGUAGE plpgsql
AS $$
DECLARE
    has_pgss boolean := to_regclass('pg_stat_statements') IS NOT NULL;
BEGIN
    RETURN QUERY
    WITH activity AS (
        SELECT
            count(*) FILTER (WHERE wait_event_type = 'Lock') AS lock_waiters,
            count(*) FILTER (WHERE xact_start < now() - interval '15 minutes') AS long_xacts,
            count(*) FILTER (WHERE state = 'active') AS active_sessions
        FROM pg_stat_activity
    ),
    xid AS (
        SELECT max(age(datfrozenxid)) AS max_xid_age FROM pg_database
    ),
    db AS (
        SELECT
            sum(temp_bytes) AS temp_bytes,
            sum(deadlocks) AS deadlocks,
            round(100 * sum(blks_hit)::numeric / NULLIF(sum(blks_hit + blks_read), 0), 2) AS cache_hit_pct
        FROM pg_stat_database
    ),
    rep AS (
        SELECT coalesce(max(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)), 0) AS lag_bytes
        FROM pg_stat_replication
    ),
    arch AS (
        SELECT failed_count FROM pg_stat_archiver
    )
    SELECT 'P1', 'lock waits detected',
           'waiters=' || lock_waiters,
           'Find blockers with pg_blocking_pids(), review blocker SQL, and decide cancel/kill only after business validation.',
           'pg_stat_activity'
    FROM activity WHERE lock_waiters > 0
    UNION ALL
    SELECT 'P1', 'archive failures detected',
           'failed_count=' || failed_count,
           'Fix archive_command/storage permissions immediately and confirm WAL archival resumes.',
           'pg_stat_archiver'
    FROM arch WHERE failed_count > 0
    UNION ALL
    SELECT 'P1', 'critical XID age',
           'max_age=' || max_xid_age,
           'Prioritize anti-wraparound vacuum, idle transaction cleanup, and table freeze backlog review.',
           'pg_database'
    FROM xid WHERE max_xid_age > 1500000000
    UNION ALL
    SELECT 'P2', 'long transactions',
           'count=' || long_xacts,
           'Review xact_start, backend_xmin, client, and application owner; long transactions can block vacuum.',
           'pg_stat_activity'
    FROM activity WHERE long_xacts > 0
    UNION ALL
    SELECT 'P2', 'deadlocks since reset',
           'deadlocks=' || deadlocks,
           'Review application transaction order, lock acquisition order, and retry behavior.',
           'pg_stat_database'
    FROM db WHERE deadlocks > 0
    UNION ALL
    SELECT 'P2', 'temp spill pressure',
           'temp_mb=' || round(temp_bytes::numeric / 1024 / 1024, 2),
           'Find spilling queries, validate work_mem, indexes, joins, sort/hash nodes, and statistics.',
           'pg_stat_database'
    FROM db WHERE temp_bytes > 1024::bigint * 1024 * 1024
    UNION ALL
    SELECT 'P2', 'replication lag',
           'lag_bytes=' || lag_bytes,
           'Check standby replay, network, WAL volume, long standby queries, and slot retention.',
           'pg_stat_replication'
    FROM rep WHERE lag_bytes > 1024::bigint * 1024 * 1024
    UNION ALL
    SELECT 'P3', 'low cache hit ratio',
           'cache_hit_pct=' || cache_hit_pct,
           'Correlate with pg_stat_io, top read queries, sequential scans, and storage latency.',
           'pg_stat_database'
    FROM db WHERE cache_hit_pct < 95;

    IF has_pgss THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'P2'::text, 'pg_stat_statements temp spill SQL'::text,
                   'queryid=' || queryid::text || ', temp_mb=' ||
                   round(((temp_blks_read + temp_blks_written) * current_setting('block_size')::numeric) / 1024 / 1024, 2)::text,
                   'Tune highest temp-spilling SQL with EXPLAIN ANALYZE, row estimates, indexes, and work_mem scope.'::text,
                   'pg_stat_statements'::text
            FROM pg_stat_statements
            WHERE temp_blks_read + temp_blks_written > 0
            ORDER BY temp_blks_read + temp_blks_written DESC
            LIMIT 10
        $sql$;
    ELSE
        RETURN QUERY
        SELECT 'P3', 'pg_stat_statements not enabled',
               'extension_missing_or_not_search_path_visible',
               'Enable pg_stat_statements for query-level CPU/time/temp/WAL diagnosis.',
               'pg_extension';
    END IF;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_root_cause_action_queue()
ORDER BY priority, symptom;

-- SAMPLE_OUTPUT_BEGIN
-- priority | symptom             | evidence  | next_action                                      | source_view
-- ---------+---------------------+-----------+--------------------------------------------------+------------------
-- P1       | lock waits detected | waiters=2 | Find blockers with pg_blocking_pids()...        | pg_stat_activity
-- SAMPLE_OUTPUT_END
