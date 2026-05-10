/*
PostgreSQL DBA Script: Create Snapshot Procedures
Purpose: Create procedures to capture periodic lifecycle/capacity snapshots and purge old history.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after repository tables are created; then schedule CALL dba_metrics.sp_capture_operational_snapshot(...).
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE OR REPLACE PROCEDURE dba_metrics.sp_capture_operational_snapshot(
    p_source text DEFAULT 'manual',
    p_notes text DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_run_id bigint;
    v_captured_at timestamptz := clock_timestamp();
    v_db_name text := current_database();
    v_stats_reset timestamptz;
BEGIN
    SELECT stats_reset
    INTO v_stats_reset
    FROM pg_stat_database
    WHERE datname = current_database();

    INSERT INTO dba_metrics.capture_run (
        captured_at,
        database_name,
        capture_source,
        notes
    )
    VALUES (
        v_captured_at,
        v_db_name,
        coalesce(nullif(trim(p_source), ''), 'manual'),
        p_notes
    )
    RETURNING run_id INTO v_run_id;

    INSERT INTO dba_metrics.index_usage_snap (
        run_id,
        captured_at,
        database_name,
        stats_reset,
        index_oid,
        table_oid,
        schema_name,
        table_name,
        index_name,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        index_size_bytes,
        table_total_size_bytes,
        is_unique,
        is_primary,
        is_valid,
        is_ready,
        is_live,
        constraint_name
    )
    SELECT
        v_run_id,
        v_captured_at,
        v_db_name,
        v_stats_reset,
        ui.indexrelid,
        ui.relid,
        ui.schemaname,
        ui.relname,
        ui.indexrelname,
        ui.idx_scan,
        ui.idx_tup_read,
        ui.idx_tup_fetch,
        pg_relation_size(ui.indexrelid),
        pg_total_relation_size(ui.relid),
        i.indisunique,
        i.indisprimary,
        i.indisvalid,
        i.indisready,
        i.indislive,
        con.conname
    FROM pg_stat_user_indexes ui
    JOIN pg_index i
      ON i.indexrelid = ui.indexrelid
    LEFT JOIN LATERAL (
        SELECT c.conname
        FROM pg_constraint c
        WHERE c.conindid = ui.indexrelid
        ORDER BY c.conname
        LIMIT 1
    ) con
      ON true;

    INSERT INTO dba_metrics.table_mod_snap (
        run_id,
        captured_at,
        database_name,
        stats_reset,
        table_oid,
        schema_name,
        table_name,
        n_tup_ins,
        n_tup_upd,
        n_tup_del,
        n_tup_hot_upd,
        n_live_tup,
        n_dead_tup,
        n_mod_since_analyze,
        vacuum_count,
        autovacuum_count,
        analyze_count,
        autoanalyze_count,
        last_vacuum,
        last_autovacuum,
        last_analyze,
        last_autoanalyze,
        table_total_size_bytes
    )
    SELECT
        v_run_id,
        v_captured_at,
        v_db_name,
        v_stats_reset,
        s.relid,
        s.schemaname,
        s.relname,
        s.n_tup_ins,
        s.n_tup_upd,
        s.n_tup_del,
        s.n_tup_hot_upd,
        s.n_live_tup,
        s.n_dead_tup,
        s.n_mod_since_analyze,
        s.vacuum_count,
        s.autovacuum_count,
        s.analyze_count,
        s.autoanalyze_count,
        s.last_vacuum,
        s.last_autovacuum,
        s.last_analyze,
        s.last_autoanalyze,
        pg_total_relation_size(s.relid)
    FROM pg_stat_user_tables s;

    INSERT INTO dba_metrics.object_size_snap (
        run_id,
        captured_at,
        database_name,
        object_oid,
        schema_name,
        object_name,
        object_type,
        relkind,
        total_size_bytes,
        relation_size_bytes,
        toast_size_bytes,
        index_size_bytes,
        estimated_rows
    )
    SELECT
        v_run_id,
        v_captured_at,
        v_db_name,
        c.oid,
        n.nspname,
        c.relname,
        CASE c.relkind
            WHEN 'r' THEN 'TABLE'
            WHEN 'p' THEN 'PARTITIONED_TABLE'
            WHEN 'm' THEN 'MATERIALIZED_VIEW'
            WHEN 'i' THEN 'INDEX'
            WHEN 'S' THEN 'SEQUENCE'
            ELSE 'OTHER'
        END AS object_type,
        c.relkind,
        pg_total_relation_size(c.oid),
        pg_relation_size(c.oid),
        CASE
            WHEN c.relkind IN ('r', 'm') AND c.reltoastrelid <> 0 THEN pg_total_relation_size(c.reltoastrelid)
            ELSE 0
        END AS toast_size_bytes,
        CASE
            WHEN c.relkind IN ('r', 'm', 'p') THEN pg_indexes_size(c.oid)
            WHEN c.relkind = 'i' THEN pg_relation_size(c.oid)
            ELSE 0
        END AS index_size_bytes,
        CASE WHEN c.reltuples >= 0 THEN c.reltuples::bigint ELSE NULL END AS estimated_rows
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'p', 'm', 'i', 'S')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema';

    INSERT INTO dba_metrics.database_size_snap (
        run_id,
        captured_at,
        database_name,
        size_bytes
    )
    VALUES (
        v_run_id,
        v_captured_at,
        v_db_name,
        pg_database_size(v_db_name)
    );

    INSERT INTO dba_metrics.tablespace_size_snap (
        run_id,
        captured_at,
        tablespace_name,
        size_bytes
    )
    SELECT
        v_run_id,
        v_captured_at,
        t.spcname,
        pg_tablespace_size(t.oid)
    FROM pg_tablespace t;

    INSERT INTO dba_metrics.db_stats_reset_snap (
        run_id,
        captured_at,
        database_name,
        stats_reset
    )
    VALUES (
        v_run_id,
        v_captured_at,
        v_db_name,
        v_stats_reset
    );
END;
$$;

CREATE OR REPLACE PROCEDURE dba_metrics.sp_purge_history(
    p_retain_months int DEFAULT 18
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff timestamptz;
BEGIN
    IF p_retain_months < 1 THEN
        RAISE EXCEPTION 'p_retain_months must be >= 1';
    END IF;

    v_cutoff := date_trunc('day', clock_timestamp()) - make_interval(months => p_retain_months);

    DELETE FROM dba_metrics.ddl_event_log
    WHERE event_ts < v_cutoff;

    DELETE FROM dba_metrics.capture_run
    WHERE captured_at < v_cutoff;
END;
$$;

SELECT
    'step_01_schema_ready' AS setup_step,
    'dba_metrics' AS object_name,
    CASE WHEN to_regnamespace('dba_metrics') IS NOT NULL THEN 'READY' ELSE 'FAILED' END AS status,
    'Schema for capture and purge procedures.' AS purpose,
    'Continue only when status is READY.' AS next_action;

SELECT
    'step_02_repository_dependencies' AS setup_step,
    object_name,
    CASE WHEN to_regclass(object_name) IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        ('dba_metrics.capture_run', 'Required by the capture procedure for run metadata.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.index_usage_snap', 'Stores index usage snapshot rows.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.table_mod_snap', 'Stores table modification snapshot rows.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.object_size_snap', 'Stores object size snapshot rows.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.database_size_snap', 'Stores database size snapshot rows.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.tablespace_size_snap', 'Stores tablespace size snapshot rows.', 'If MISSING, run 01_create_lifecycle_repository.sql.'),
        ('dba_metrics.db_stats_reset_snap', 'Stores stats reset timestamps for delta trust checks.', 'If MISSING, run 01_create_lifecycle_repository.sql.')
) AS d(object_name, purpose, next_action)
ORDER BY object_name;

SELECT
    'step_03_procedure_status' AS setup_step,
    procedure_name AS object_name,
    CASE WHEN to_regprocedure(procedure_signature) IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        (
            'dba_metrics.sp_capture_operational_snapshot',
            'dba_metrics.sp_capture_operational_snapshot(text,text)',
            'Captures index usage, table DML, object size, database size, tablespace size, and stats reset snapshots.',
            'Run CALL dba_metrics.sp_capture_operational_snapshot(''manual'', ''first capture'');'
        ),
        (
            'dba_metrics.sp_purge_history',
            'dba_metrics.sp_purge_history(integer)',
            'Purges old capture and DDL event history after the retention window.',
            'Run CALL dba_metrics.sp_purge_history(18); during planned maintenance.'
        )
) AS p(procedure_name, procedure_signature, purpose, next_action)
ORDER BY procedure_name;

SELECT
    'step_04_next_steps' AS setup_step,
    step_order,
    task_name,
    purpose,
    sql_to_run
FROM (
    VALUES
        (1, 'capture_now', 'Take the first baseline snapshot.', 'Run 37_object_lifecycle_capacity/04_capture_snapshot_now.sql'),
        (2, 'schedule_capture', 'Keep history current for growth and lifecycle decisions.', 'Run 37_object_lifecycle_capacity/09_scheduler_runbook.sql'),
        (3, 'create_reporting_views', 'Create lifecycle, modification, growth, and advisory views.', 'Run scripts 05, 06, 07, and 08.')
) AS s(step_order, task_name, purpose, sql_to_run)
ORDER BY step_order;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE PROCEDURE
-- CREATE PROCEDURE
-- SAMPLE_OUTPUT_END
