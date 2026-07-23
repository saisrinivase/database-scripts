/*
PostgreSQL DBA Script: PgAdmin Safe CloudWatch Metric Equivalents
Purpose: pgAdmin-safe SQL equivalents for common database-side CloudWatch/RDS-style metrics.
Scope: Connections, transactions, locks, temp usage, cache hit, replication lag, WAL generation, archiver failures, and checkpoints.
pgAdmin: Safe to run in Query Tool. Uses only catalog views and a temporary helper function.
Sample output:
 metric_name              | metric_value | unit    | source_view       | diagnosis
--------------------------+--------------+---------+-------------------+----------------------------
 DatabaseConnections      | 42           | count   | pg_stat_activity  | Watch max_connections headroom.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_cloudwatch_equivalents()
RETURNS TABLE (
    metric_name text,
    metric_value numeric,
    unit text,
    source_view text,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 'DatabaseConnections'::text, count(*)::numeric, 'count'::text, 'pg_stat_activity'::text,
           'Current server sessions. Compare with max_connections and pooler capacity.'::text
    FROM pg_stat_activity
    UNION ALL
    SELECT 'ActiveTransactions', count(*)::numeric, 'count', 'pg_stat_activity',
           'Active sessions currently executing or holding transaction work.'
    FROM pg_stat_activity
    WHERE state = 'active'
    UNION ALL
    SELECT 'LongRunningTransactions', count(*)::numeric, 'count', 'pg_stat_activity',
           'Transactions older than 15 minutes can block vacuum and increase bloat/XID risk.'
    FROM pg_stat_activity
    WHERE xact_start < now() - interval '15 minutes'
    UNION ALL
    SELECT 'LockWaiters', count(*)::numeric, 'count', 'pg_locks/pg_stat_activity',
           'Sessions waiting on locks. Investigate blockers before tuning SQL.'
    FROM pg_stat_activity
    WHERE wait_event_type = 'Lock'
    UNION ALL
    SELECT 'DeadlocksSinceStatsReset', coalesce(sum(deadlocks), 0)::numeric, 'count', 'pg_stat_database',
           'Deadlocks indicate application ordering or transaction design issues.'
    FROM pg_stat_database
    UNION ALL
    SELECT 'TempBytesSinceStatsReset', coalesce(sum(temp_bytes), 0)::numeric / 1024 / 1024, 'MB', 'pg_stat_database',
           'Temp file usage points to sort/hash spills, low work_mem, or bad plans.'
    FROM pg_stat_database
    UNION ALL
    SELECT 'CacheHitRatio', round(100 * sum(blks_hit)::numeric / NULLIF(sum(blks_hit + blks_read), 0), 2), 'percent', 'pg_stat_database',
           'Low value can indicate read pressure, undersized cache, or scan-heavy SQL.'
    FROM pg_stat_database
    UNION ALL
    SELECT 'XidAgeMax', max(age(datfrozenxid))::numeric, 'transactions', 'pg_database',
           'High XID age requires urgent vacuum/freeze review.'
    FROM pg_database
    UNION ALL
    SELECT 'ReplicationLagMax', coalesce(max(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)), 0)::numeric, 'bytes', 'pg_stat_replication',
           'Primary-side physical replication lag in bytes.'
    FROM pg_stat_replication
    UNION ALL
    SELECT 'ArchivedWalFailures', failed_count::numeric, 'count', 'pg_stat_archiver',
           'Archive failures can break PITR and fill WAL storage.'
    FROM pg_stat_archiver;

    IF to_regclass('pg_catalog.pg_stat_wal') IS NOT NULL THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'WalBytesSinceStatsReset'::text, wal_bytes::numeric, 'bytes'::text, 'pg_stat_wal'::text,
                   'WAL generated since statistics reset. Correlate with write-heavy SQL and checkpoints.'::text
            FROM pg_stat_wal
        $sql$;
    END IF;

    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'RequestedCheckpointPct'::text,
                   round(100 * num_requested::numeric / NULLIF(num_timed + num_requested, 0), 2),
                   'percent'::text,
                   'pg_stat_checkpointer'::text,
                   'High requested checkpoint ratio usually means max_wal_size/checkpoint_timeout is too small.'::text
            FROM pg_stat_checkpointer
        $sql$;
    ELSE
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'RequestedCheckpointPct'::text,
                   round(100 * checkpoints_req::numeric / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                   'percent'::text,
                   'pg_stat_bgwriter'::text,
                   'High requested checkpoint ratio usually means max_wal_size/checkpoint_timeout is too small.'::text
            FROM pg_stat_bgwriter
        $sql$;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_cloudwatch_equivalents()
ORDER BY metric_name;

-- SAMPLE_OUTPUT_BEGIN
-- metric_name         | metric_value | unit    | source_view      | diagnosis
-- -------------------+--------------+---------+------------------+------------------------------
-- DatabaseConnections | 42           | count   | pg_stat_activity | Current server sessions...
-- SAMPLE_OUTPUT_END
