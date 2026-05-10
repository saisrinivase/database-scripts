/*
PostgreSQL DBA Script: Parameter Deviation Necessity Report
Purpose: Find parameter deviations and tuning necessities in one run by combining pg_settings
         with available PostgreSQL workload evidence.
Area: Configuration Parameters
Usage: Run in pgAdmin, psql, or any SQL client. Read severity, necessity_reason, and recommended_action.
       Optional timestamp placeholders when using your own settings/stat snapshot tables:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Recommendations are evidence-based starting points; validate changes in staging.
*/
WITH setting_rows AS (
    SELECT
        name,
        setting,
        unit,
        source,
        boot_val,
        reset_val,
        pending_restart,
        short_desc,
        context,
        vartype,
        CASE
            WHEN unit IN ('B', 'kB', '8kB', 'MB', 'GB') THEN pg_size_bytes(setting || unit)
            ELSE NULL::bigint
        END AS bytes_value,
        CASE
            WHEN unit IN ('B', 'kB', '8kB', 'MB', 'GB') THEN pg_size_bytes(reset_val || unit)
            ELSE NULL::bigint
        END AS reset_bytes_value
    FROM pg_settings
    WHERE name IN (
        'autovacuum',
        'autovacuum_analyze_scale_factor',
        'autovacuum_max_workers',
        'autovacuum_naptime',
        'autovacuum_vacuum_cost_delay',
        'autovacuum_vacuum_scale_factor',
        'checkpoint_completion_target',
        'default_statistics_target',
        'effective_cache_size',
        'effective_io_concurrency',
        'hash_mem_multiplier',
        'jit',
        'maintenance_work_mem',
        'max_connections',
        'max_parallel_workers',
        'max_parallel_workers_per_gather',
        'max_wal_size',
        'random_page_cost',
        'shared_buffers',
        'shared_preload_libraries',
        'track_functions',
        'track_io_timing',
        'track_wal_io_timing',
        'wal_compression',
        'work_mem'
    )
),
evidence AS (
    SELECT
        (SELECT count(*) FROM pg_stat_activity) AS current_connections,
        (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
        (SELECT count(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS idle_in_txn_connections,
        (SELECT count(*) FROM pg_locks WHERE NOT granted) AS waiting_locks,
        (SELECT coalesce(sum(temp_bytes), 0) FROM pg_stat_database WHERE datname NOT IN ('template0', 'template1')) AS temp_bytes,
        (SELECT coalesce(sum(temp_files), 0) FROM pg_stat_database WHERE datname NOT IN ('template0', 'template1')) AS temp_files,
        (SELECT round(100.0 * sum(blks_hit) / NULLIF(sum(blks_hit) + sum(blks_read), 0), 2)
         FROM pg_stat_database
         WHERE datname NOT IN ('template0', 'template1')) AS cache_hit_pct,
        (SELECT coalesce(sum(deadlocks), 0) FROM pg_stat_database WHERE datname NOT IN ('template0', 'template1')) AS deadlocks,
        (SELECT coalesce(max(age(datfrozenxid)), 0) FROM pg_database) AS max_database_xid_age,
        (SELECT count(*) FROM pg_stat_user_tables WHERE n_dead_tup > greatest(n_live_tup * 0.20, 10000)) AS dead_tuple_hotspot_tables,
        (SELECT count(*) FROM pg_stat_user_tables WHERE n_mod_since_analyze > greatest(n_live_tup * 0.10, 10000)) AS stale_analyze_tables,
        (SELECT coalesce(sum(wal_buffers_full), 0) FROM pg_stat_wal) AS wal_buffers_full,
        (SELECT coalesce(sum(wal_bytes), 0) FROM pg_stat_wal) AS wal_bytes,
        (SELECT coalesce(count(*), 0) FROM pg_stat_replication) AS standby_count,
        (SELECT coalesce(count(*), 0) FROM pg_replication_slots WHERE restart_lsn IS NOT NULL) AS replication_slot_count
),
checkpoint_evidence AS (
    SELECT
        NULL::numeric AS requested_checkpoint_pct_pg15_16
),
rules AS (
    SELECT
        s.name AS parameter,
        s.setting AS current_setting,
        s.unit,
        s.source,
        s.boot_val,
        s.reset_val,
        s.pending_restart,
        CASE
            WHEN s.source <> 'default' THEN 'NON_DEFAULT'
            ELSE 'DEFAULT'
        END AS deviation_type,
        CASE
            WHEN s.setting IS DISTINCT FROM s.reset_val THEN 'RESET_DIFFERS'
            ELSE 'RESET_MATCHES'
        END AS reset_drift,
        s.context,
        s.short_desc,
        CASE s.name
            WHEN 'work_mem' THEN
                CASE
                    WHEN e.temp_bytes >= 10::bigint * 1024 * 1024 * 1024 THEN 'HIGH'
                    WHEN e.temp_bytes > 0 THEN 'MEDIUM'
                    ELSE 'OK'
                END
            WHEN 'shared_buffers' THEN
                CASE
                    WHEN e.cache_hit_pct < 95 AND s.bytes_value < 1024::bigint * 1024 * 1024 THEN 'HIGH'
                    WHEN e.cache_hit_pct < 98 THEN 'MEDIUM'
                    ELSE 'OK'
                END
            WHEN 'effective_cache_size' THEN
                CASE
                    WHEN s.bytes_value < (SELECT bytes_value FROM setting_rows WHERE name = 'shared_buffers') * 2 THEN 'MEDIUM'
                    ELSE 'OK'
                END
            WHEN 'max_connections' THEN
                CASE
                    WHEN e.current_connections >= s.setting::int * 0.90 THEN 'HIGH'
                    WHEN e.current_connections >= s.setting::int * 0.75 OR s.setting::int > 500 THEN 'MEDIUM'
                    ELSE 'OK'
                END
            WHEN 'max_wal_size' THEN
                CASE
                    WHEN ce.requested_checkpoint_pct_pg15_16 > 20 OR e.wal_buffers_full > 0 THEN 'MEDIUM'
                    ELSE 'OK'
                END
            WHEN 'checkpoint_completion_target' THEN
                CASE WHEN s.setting::numeric < 0.7 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'autovacuum' THEN
                CASE WHEN s.setting = 'off' THEN 'HIGH' ELSE 'OK' END
            WHEN 'autovacuum_max_workers' THEN
                CASE WHEN e.dead_tuple_hotspot_tables >= 10 AND s.setting::int < 5 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'autovacuum_vacuum_scale_factor' THEN
                CASE WHEN e.dead_tuple_hotspot_tables > 0 AND s.setting::numeric >= 0.2 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'autovacuum_analyze_scale_factor' THEN
                CASE WHEN e.stale_analyze_tables > 0 AND s.setting::numeric >= 0.1 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'random_page_cost' THEN
                CASE WHEN s.setting::numeric > 2.5 AND e.cache_hit_pct >= 95 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'track_io_timing' THEN
                CASE WHEN s.setting = 'off' THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'track_wal_io_timing' THEN
                CASE WHEN s.setting = 'off' THEN 'LOW' ELSE 'OK' END
            WHEN 'shared_preload_libraries' THEN
                CASE WHEN s.setting NOT ILIKE '%pg_stat_statements%' THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'max_parallel_workers' THEN
                CASE WHEN s.setting::int = 0 THEN 'MEDIUM' ELSE 'OK' END
            WHEN 'max_parallel_workers_per_gather' THEN
                CASE WHEN s.setting::int = 0 THEN 'LOW' ELSE 'OK' END
            ELSE
                CASE WHEN s.source <> 'default' THEN 'INFO' ELSE 'OK' END
        END AS severity,
        CASE s.name
            WHEN 'work_mem' THEN format('temp_bytes=%s, temp_files=%s. Temp spills indicate sort/hash operations exceeded available memory.', pg_size_pretty(e.temp_bytes), e.temp_files)
            WHEN 'shared_buffers' THEN format('cache_hit_pct=%s. Low cache hit with small shared_buffers can increase physical reads.', coalesce(e.cache_hit_pct::text, 'n/a'))
            WHEN 'effective_cache_size' THEN 'Planner cache estimate should usually be larger than shared_buffers so index plans are not unfairly penalized.'
            WHEN 'max_connections' THEN format('current_connections=%s, active_connections=%s, idle_in_txn=%s. High direct connections can reduce throughput.', e.current_connections, e.active_connections, e.idle_in_txn_connections)
            WHEN 'max_wal_size' THEN format('requested_checkpoint_pct_pg15_16=%s, wal_buffers_full=%s. Frequent requested checkpoints or WAL buffer pressure suggests WAL/checkpoint tuning review.', coalesce(ce.requested_checkpoint_pct_pg15_16::text, 'use pg_stat_checkpointer on PG17+'), e.wal_buffers_full)
            WHEN 'checkpoint_completion_target' THEN 'Low checkpoint_completion_target can make checkpoint writes bursty.'
            WHEN 'autovacuum' THEN format('dead_tuple_hotspot_tables=%s, max_database_xid_age=%s. Autovacuum protects against bloat and xid wraparound.', e.dead_tuple_hotspot_tables, e.max_database_xid_age)
            WHEN 'autovacuum_max_workers' THEN format('dead_tuple_hotspot_tables=%s. More concurrent workers may be needed when many tables are behind.', e.dead_tuple_hotspot_tables)
            WHEN 'autovacuum_vacuum_scale_factor' THEN format('dead_tuple_hotspot_tables=%s. Large tables often need lower per-table scale factors.', e.dead_tuple_hotspot_tables)
            WHEN 'autovacuum_analyze_scale_factor' THEN format('stale_analyze_tables=%s. Stale stats can cause bad plans.', e.stale_analyze_tables)
            WHEN 'random_page_cost' THEN format('cache_hit_pct=%s. On SSD/cloud storage, very high random_page_cost can discourage useful index scans.', coalesce(e.cache_hit_pct::text, 'n/a'))
            WHEN 'track_io_timing' THEN 'Needed to prove storage latency from pg_stat_database and pg_stat_io.'
            WHEN 'track_wal_io_timing' THEN 'Needed to prove WAL write/sync timing where supported.'
            WHEN 'shared_preload_libraries' THEN 'pg_stat_statements is required for top SQL history and query attribution.'
            WHEN 'max_parallel_workers' THEN 'Parallel query can help analytical scans and aggregates when workload allows it.'
            WHEN 'max_parallel_workers_per_gather' THEN 'Per-query parallelism is disabled when this is zero.'
            ELSE 'Parameter is included for drift visibility.'
        END AS necessity_reason,
        CASE s.name
            WHEN 'work_mem' THEN 'Do not increase globally blindly. Find top temp spill SQL, tune plan/indexes first, then consider session/role-level work_mem for proven queries.'
            WHEN 'shared_buffers' THEN 'For dedicated DB hosts, validate 15-30% RAM range with cache hit, OS cache, and restart planning.'
            WHEN 'effective_cache_size' THEN 'Set to estimated OS cache plus shared_buffers available to PostgreSQL; no restart usually required.'
            WHEN 'max_connections' THEN 'Prefer connection pooling before increasing. If near limit, check pool config and idle sessions.'
            WHEN 'max_wal_size' THEN 'Review checkpoint cadence and storage. Consider larger max_wal_size if requested checkpoint percentage is high.'
            WHEN 'checkpoint_completion_target' THEN 'Use 0.7-0.9 for smoother checkpoint writes unless workload testing says otherwise.'
            WHEN 'autovacuum' THEN 'Keep enabled. If disabled, enable urgently after change review.'
            WHEN 'autovacuum_max_workers' THEN 'Increase with cost limits and IO capacity in mind, or tune table-level autovacuum settings.'
            WHEN 'autovacuum_vacuum_scale_factor' THEN 'Use lower table-level scale factors for large/high-churn tables instead of only global changes.'
            WHEN 'autovacuum_analyze_scale_factor' THEN 'Use lower table-level analyze scale factors for volatile tables.'
            WHEN 'random_page_cost' THEN 'Benchmark lower values such as 1.1-2.0 on SSD/cloud storage before production change.'
            WHEN 'track_io_timing' THEN 'Enable when diagnostic value outweighs small timing overhead.'
            WHEN 'track_wal_io_timing' THEN 'Enable for WAL latency diagnosis where supported.'
            WHEN 'shared_preload_libraries' THEN 'Add pg_stat_statements and restart during a maintenance window if missing.'
            WHEN 'max_parallel_workers' THEN 'Enable/tune for reporting workloads; verify OLTP impact.'
            WHEN 'max_parallel_workers_per_gather' THEN 'Use nonzero values for analytical workloads; validate query plans.'
            ELSE 'Review why this is non-default and whether it is still intentional.'
        END AS recommended_action
    FROM setting_rows s
    CROSS JOIN evidence e
    CROSS JOIN checkpoint_evidence ce
)
SELECT
    parameter,
    current_setting,
    unit,
    source,
    boot_val,
    reset_val,
    pending_restart,
    deviation_type,
    reset_drift,
    severity,
    necessity_reason,
    recommended_action,
    context,
    short_desc
FROM rules
ORDER BY
    CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 WHEN 'INFO' THEN 4 ELSE 5 END,
    CASE deviation_type WHEN 'NON_DEFAULT' THEN 1 ELSE 2 END,
    parameter;


-- SAMPLE_OUTPUT_BEGIN
-- parameter      | current_setting | unit | source             | deviation_type | severity | necessity_reason
-- ---------------+-----------------+------+--------------------+----------------+----------+------------------------------
-- work_mem       | 4096            | kB   | default            | DEFAULT        | MEDIUM   | temp_bytes=12 GB...
-- max_wal_size   | 1024            | MB   | configuration file | NON_DEFAULT    | MEDIUM   | requested_checkpoint_pct...
-- track_io_timing| off             |      | default            | DEFAULT        | MEDIUM   | Needed to prove storage latency...
-- SAMPLE_OUTPUT_END
