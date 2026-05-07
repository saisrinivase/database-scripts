/*
PostgreSQL DBA Script: Top Root Cause Action Queue
Purpose: Build a prioritized action queue from live signals and pg_stat_statements hotspots.
Area: Observer Agent Monitoring
Usage: Run after detecting an issue to decide the next DBA action in priority order.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. pg_stat_statements section appears only when the extension/view is available.
*/
SELECT (to_regclass('pg_stat_statements') IS NOT NULL) AS has_pgss \gset

WITH action_queue AS (
    SELECT
        10 AS priority,
        'blocking_locks' AS root_cause,
        count(*)::numeric AS evidence_value,
        'waiting locks' AS evidence_unit,
        'Sessions are blocked by locks.' AS evidence,
        'Run blocker detail and resolve the blocking transaction first.' AS action,
        '06_activity_locks/02_blocking_and_blocked_sessions.sql' AS next_script
    FROM pg_locks
    WHERE NOT granted
    HAVING count(*) > 0
    UNION ALL
    SELECT
        20,
        'long_transactions',
        count(*)::numeric,
        'transactions',
        'Transactions older than 15 minutes are present.',
        'Find owners and close/cancel safely to unblock vacuum and locks.',
        '06_activity_locks/03_long_running_transactions.sql'
    FROM pg_stat_activity
    WHERE xact_start IS NOT NULL
      AND now() - xact_start > interval '15 minutes'
    HAVING count(*) > 0
    UNION ALL
    SELECT
        30,
        'long_queries',
        count(*)::numeric,
        'queries',
        'Active queries older than 5 minutes are present.',
        'Inspect wait events and generate EXPLAIN for the query shape.',
        '18_long_queries_full_scans/01_active_long_queries.sql'
    FROM pg_stat_activity
    WHERE state = 'active'
      AND query_start IS NOT NULL
      AND now() - query_start > interval '5 minutes'
    HAVING count(*) > 0
    UNION ALL
    SELECT
        40,
        'replication_slot_wal_retention',
        max(pg_wal_lsn_diff(CASE WHEN pg_is_in_recovery() THEN pg_last_wal_receive_lsn() ELSE pg_current_wal_lsn() END, restart_lsn)),
        'bytes',
        'One or more replication slots retain WAL.',
        'Check inactive slots and downstream replication consumers.',
        '08_replication_ha/03_replication_slots_health.sql'
    FROM pg_replication_slots
    WHERE restart_lsn IS NOT NULL
    HAVING max(pg_wal_lsn_diff(CASE WHEN pg_is_in_recovery() THEN pg_last_wal_receive_lsn() ELSE pg_current_wal_lsn() END, restart_lsn)) >= 1073741824
    UNION ALL
    SELECT
        50,
        'stale_statistics',
        max(n_mod_since_analyze)::numeric,
        'modified rows',
        'Tables have high modifications since last analyze.',
        'Refresh statistics or tune autovacuum analyze thresholds.',
        '12_planner_statistics/01_tables_needing_analyze.sql'
    FROM pg_stat_user_tables
    HAVING max(n_mod_since_analyze) > 100000
    UNION ALL
    SELECT
        60,
        'dead_tuple_pressure',
        max(n_dead_tup)::numeric,
        'dead tuples',
        'Tables have high dead tuple counts.',
        'Review autovacuum progress, long transactions, and table-level vacuum settings.',
        '07_vacuum_bloat/04_dead_tuples_hotspots.sql'
    FROM pg_stat_user_tables
    HAVING max(n_dead_tup) > 10000
    UNION ALL
    SELECT
        70,
        'sequential_scan_pressure',
        max(seq_tup_read)::numeric,
        'tuples read by seq scan',
        'Large sequential scan pressure is visible.',
        'Validate predicates and candidate indexes before adding indexes.',
        '27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql'
    FROM pg_stat_user_tables
    HAVING max(seq_tup_read) > 1000000
)
SELECT
    priority,
    root_cause,
    evidence_value,
    evidence_unit,
    evidence,
    action,
    next_script
FROM action_queue
ORDER BY priority, evidence_value DESC NULLS LAST;

\if :has_pgss
SELECT
    80 AS priority,
    'top_sql_total_time' AS root_cause,
    round(total_exec_time::numeric, 2) AS evidence_value,
    'ms total_exec_time' AS evidence_unit,
    'Statement is one of the largest cumulative runtime contributors.' AS evidence,
    'Review plan, rows, IO, temp, WAL, and execution variance before changing SQL/indexes.' AS action,
    '17_execution_plans/03_generate_explain_for_top_queries.sql' AS next_script,
    left(regexp_replace(query, '\s+', ' ', 'g'), 180) AS query_sample
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
\else
SELECT
    'pg_stat_statements is not available; top SQL action queue is skipped. Run 38_observability_360/10_query_capture_quality_pgss.sql.' AS guidance;
\endif

-- SAMPLE_OUTPUT_BEGIN
-- priority | root_cause       | evidence_value | evidence_unit | evidence
-- ---------+------------------+----------------+---------------+--------------------------------------
--       10 | blocking_locks   |              2 | waiting locks | Sessions are blocked by locks.
--       50 | stale_statistics |        2500000 | modified rows | Tables have high modifications...
-- SAMPLE_OUTPUT_END
