/*
PostgreSQL DBA Script: Cloud Portability Capability Matrix
Purpose: Show which diagnostics are available to the current login on PostgreSQL 15+ and where provider or OS metrics are still required.
Area: Internals Deep Dive
Usage: Run first on RDS, Aurora PostgreSQL, Cloud SQL, AlloyDB, Azure Database for PostgreSQL, or self-managed PostgreSQL.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for a representative result shape.
Notes: Read-only and extension-free. A PASS means the SQL surface is present, not that the provider exposes host-level metrics.
*/
WITH identity AS (
    SELECT
        current_user AS login_role,
        rolsuper,
        pg_has_role(current_user, 'pg_monitor', 'MEMBER') AS has_pg_monitor,
        pg_has_role(current_user, 'pg_read_all_stats', 'MEMBER') AS has_pg_read_all_stats,
        current_setting('server_version_num')::integer AS server_version_num
    FROM pg_roles
    WHERE rolname = current_user
),
capabilities(capability, required_for, object_name, minimum_version, provider_metric_required) AS (
    VALUES
        ('session_activity', 'queries, waits, transactions, blockers', 'pg_catalog.pg_stat_activity', 150000, false),
        ('lock_graph', 'blocking and deadlock investigation', 'pg_catalog.pg_locks', 150000, false),
        ('vacuum_progress', 'running VACUUM phase and progress', 'pg_catalog.pg_stat_progress_vacuum', 150000, false),
        ('analyze_progress', 'running ANALYZE phase and progress', 'pg_catalog.pg_stat_progress_analyze', 150000, false),
        ('wal_statistics', 'WAL generation and sync pressure', 'pg_catalog.pg_stat_wal', 150000, false),
        ('replication_slots', 'WAL retention and logical/physical consumer health', 'pg_catalog.pg_replication_slots', 150000, false),
        ('archiver_statistics', 'archive/PITR shipping evidence', 'pg_catalog.pg_stat_archiver', 150000, false),
        ('bgwriter_statistics', 'dirty-buffer and allocation pressure', 'pg_catalog.pg_stat_bgwriter', 150000, false),
        ('checkpointer_statistics', 'checkpoint pressure on PostgreSQL 17+', 'pg_catalog.pg_stat_checkpointer', 170000, false),
        ('io_statistics', 'backend/object/context I/O on PostgreSQL 16+', 'pg_catalog.pg_stat_io', 160000, false),
        ('slru_statistics', 'XID, multixact, subtransaction SLRU pressure', 'pg_catalog.pg_stat_slru', 150000, false),
        ('statement_statistics', 'query resource attribution', 'public.pg_stat_statements', 150000, false),
        ('host_cpu', 'CPU utilization and steal time', NULL, 150000, true),
        ('host_memory', 'free memory, swap, and OOM pressure', NULL, 150000, true),
        ('filesystem_free_space', 'remaining data/WAL filesystem capacity', NULL, 150000, true),
        ('storage_queue_latency', 'IOPS, queue depth, throughput, read/write latency', NULL, 150000, true),
        ('network', 'throughput, retransmits, and packet loss', NULL, 150000, true)
),
evaluated AS (
    SELECT
        c.*,
        i.login_role,
        i.rolsuper,
        i.has_pg_monitor,
        i.has_pg_read_all_stats,
        i.server_version_num,
        CASE
            WHEN c.provider_metric_required THEN 'PROVIDER_REQUIRED'
            WHEN i.server_version_num < c.minimum_version THEN 'VERSION_NOT_AVAILABLE'
            WHEN to_regclass(c.object_name) IS NULL THEN 'NOT_AVAILABLE'
            WHEN has_table_privilege(current_user, to_regclass(c.object_name), 'SELECT')
              OR i.rolsuper
              OR i.has_pg_monitor
              OR i.has_pg_read_all_stats THEN 'PASS'
            ELSE 'LIMITED'
        END AS capability_status
    FROM capabilities c
    CROSS JOIN identity i
)
SELECT
    capability,
    required_for,
    capability_status,
    object_name,
    login_role,
    rolsuper,
    has_pg_monitor,
    has_pg_read_all_stats,
    CASE
        WHEN capability_status = 'PASS' THEN 'The built-in SQL diagnostic surface is available.'
        WHEN capability_status = 'LIMITED' THEN 'Ask for pg_monitor or pg_read_all_stats according to least-privilege policy.'
        WHEN capability_status = 'VERSION_NOT_AVAILABLE' THEN 'Use the version-compatible repository script or provider equivalent.'
        WHEN capability_status = 'PROVIDER_REQUIRED' THEN 'Use CloudWatch, Enhanced Monitoring, Performance Insights, Azure Monitor, Cloud Monitoring, or OS tooling.'
        ELSE 'The object is absent or provider-restricted; use the documented fallback.'
    END AS action
FROM evaluated
ORDER BY
    CASE capability_status
        WHEN 'LIMITED' THEN 1
        WHEN 'NOT_AVAILABLE' THEN 2
        WHEN 'VERSION_NOT_AVAILABLE' THEN 3
        WHEN 'PROVIDER_REQUIRED' THEN 4
        ELSE 5
    END,
    capability;

-- Validate that query text visibility is sufficient for diagnosis.
SELECT
    count(*) FILTER (WHERE pid <> pg_backend_pid()) AS other_backends_visible,
    count(*) FILTER (
        WHERE pid <> pg_backend_pid()
          AND query = '<insufficient privilege>'
    ) AS query_texts_hidden,
    CASE
        WHEN count(*) FILTER (
            WHERE pid <> pg_backend_pid()
              AND query = '<insufficient privilege>'
        ) > 0 THEN 'LIMITED: some complete SQL texts are hidden; request pg_read_all_stats or pg_monitor if policy permits.'
        ELSE 'PASS: no privilege-redacted SQL text is visible in this snapshot.'
    END AS query_visibility_diagnosis
FROM pg_stat_activity;

-- SAMPLE_OUTPUT_BEGIN
-- capability          | capability_status | object_name                  | action
-- session_activity    | PASS              | pg_catalog.pg_stat_activity | The built-in SQL diagnostic surface is available.
-- host_cpu            | PROVIDER_REQUIRED |                              | Use the cloud provider or OS tooling.
-- SAMPLE_OUTPUT_END
