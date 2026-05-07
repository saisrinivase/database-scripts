/*
PostgreSQL DBA Script: Create Ddl Event Triggers
Purpose: Create DDL event triggers to capture object create/alter/drop timestamps for lifecycle monitoring.
Area: Object Lifecycle and Capacity Monitoring
Usage: Requires superuser. If not superuser, script returns guidance and skips trigger creation.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (current_setting('is_superuser') = 'on') AS is_superuser \gset

\if :is_superuser
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE OR REPLACE FUNCTION dba_metrics.fn_log_ddl_command_end()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
    cmd record;
BEGIN
    FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
    LOOP
        INSERT INTO dba_metrics.ddl_event_log (
            event_ts,
            event_kind,
            command_tag,
            object_type,
            schema_name,
            object_identity,
            in_extension,
            username,
            txid,
            details
        )
        VALUES (
            clock_timestamp(),
            'ddl_command_end',
            cmd.command_tag,
            cmd.object_type,
            cmd.schema_name,
            cmd.object_identity,
            cmd.in_extension,
            session_user,
            txid_current_if_assigned(),
            jsonb_build_object(
                'classid', cmd.classid::text,
                'objid', cmd.objid::text,
                'objsubid', cmd.objsubid
            )
        );
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION dba_metrics.fn_log_sql_drop()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
    LOOP
        INSERT INTO dba_metrics.ddl_event_log (
            event_ts,
            event_kind,
            command_tag,
            object_type,
            schema_name,
            object_identity,
            in_extension,
            username,
            txid,
            details
        )
        VALUES (
            clock_timestamp(),
            'sql_drop',
            'DROP',
            obj.object_type,
            obj.schema_name,
            obj.object_identity,
            NULL,
            session_user,
            txid_current_if_assigned(),
            jsonb_build_object(
                'is_temporary', obj.is_temporary,
                'original', obj.original,
                'normal', obj.normal,
                'object_name', obj.object_name,
                'object_type', obj.object_type
            )
        );
    END LOOP;
END;
$$;

DROP EVENT TRIGGER IF EXISTS trg_dba_metrics_ddl_end;
CREATE EVENT TRIGGER trg_dba_metrics_ddl_end
    ON ddl_command_end
    EXECUTE FUNCTION dba_metrics.fn_log_ddl_command_end();

DROP EVENT TRIGGER IF EXISTS trg_dba_metrics_sql_drop;
CREATE EVENT TRIGGER trg_dba_metrics_sql_drop
    ON sql_drop
    EXECUTE FUNCTION dba_metrics.fn_log_sql_drop();

SELECT
    'EVENT_TRIGGER_ENABLED' AS status,
    'trg_dba_metrics_ddl_end and trg_dba_metrics_sql_drop are active.' AS note;
\else
SELECT
    'EVENT_TRIGGER_SKIPPED' AS status,
    'Superuser is required to create event triggers. Run this script as superuser to track created/dropped timestamps.' AS note;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE FUNCTION
-- CREATE FUNCTION
-- DROP EVENT TRIGGER
-- CREATE EVENT TRIGGER
-- DROP EVENT TRIGGER
-- CREATE EVENT TRIGGER
--         status         |                               note                               
-- -----------------------+------------------------------------------------------------------
--  EVENT_TRIGGER_ENABLED | trg_dba_metrics_ddl_end and trg_dba_metrics_sql_drop are active.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
