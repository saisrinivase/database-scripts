/*
PostgreSQL DBA Script: Create Ddl Event Triggers
Purpose: Create DDL event triggers to capture object create/alter/drop timestamps for lifecycle monitoring.
Area: Object Lifecycle and Capacity Monitoring
Usage: Requires superuser. In pgAdmin or psql, non-superusers get guidance output instead of script failure.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Creates event trigger functions and event triggers only when connected as superuser.
*/

CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE TABLE IF NOT EXISTS dba_metrics.ddl_event_log (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_ts timestamptz NOT NULL DEFAULT clock_timestamp(),
    event_kind text NOT NULL,
    command_tag text,
    object_type text,
    schema_name text,
    object_identity text,
    in_extension boolean,
    username text NOT NULL DEFAULT session_user,
    txid bigint,
    details jsonb
);

DO $$
BEGIN
    IF current_setting('is_superuser') = 'on' THEN
        EXECUTE $ddl$
            CREATE OR REPLACE FUNCTION dba_metrics.fn_log_ddl_command_end()
            RETURNS event_trigger
            LANGUAGE plpgsql
            AS $fn$
            DECLARE
                cmd record;
            BEGIN
                FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
                LOOP
                    INSERT INTO dba_metrics.ddl_event_log (
                        event_ts, event_kind, command_tag, object_type, schema_name,
                        object_identity, in_extension, username, txid, details
                    )
                    VALUES (
                        clock_timestamp(), 'ddl_command_end', cmd.command_tag, cmd.object_type,
                        cmd.schema_name, cmd.object_identity, cmd.in_extension, session_user,
                        txid_current_if_assigned(),
                        jsonb_build_object('classid', cmd.classid::text, 'objid', cmd.objid::text, 'objsubid', cmd.objsubid)
                    );
                END LOOP;
            END;
            $fn$;
        $ddl$;

        EXECUTE $ddl$
            CREATE OR REPLACE FUNCTION dba_metrics.fn_log_sql_drop()
            RETURNS event_trigger
            LANGUAGE plpgsql
            AS $fn$
            DECLARE
                obj record;
            BEGIN
                FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
                LOOP
                    INSERT INTO dba_metrics.ddl_event_log (
                        event_ts, event_kind, command_tag, object_type, schema_name,
                        object_identity, in_extension, username, txid, details
                    )
                    VALUES (
                        clock_timestamp(), 'sql_drop', 'DROP', obj.object_type,
                        obj.schema_name, obj.object_identity, NULL, session_user,
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
            $fn$;
        $ddl$;

        EXECUTE 'DROP EVENT TRIGGER IF EXISTS trg_dba_metrics_ddl_end';
        EXECUTE 'CREATE EVENT TRIGGER trg_dba_metrics_ddl_end ON ddl_command_end EXECUTE FUNCTION dba_metrics.fn_log_ddl_command_end()';
        EXECUTE 'DROP EVENT TRIGGER IF EXISTS trg_dba_metrics_sql_drop';
        EXECUTE 'CREATE EVENT TRIGGER trg_dba_metrics_sql_drop ON sql_drop EXECUTE FUNCTION dba_metrics.fn_log_sql_drop()';
    END IF;
END $$;

SELECT
    'step_01_superuser_check' AS setup_step,
    current_user AS connected_user,
    CASE WHEN current_setting('is_superuser') = 'on' THEN 'READY' ELSE 'SKIPPED' END AS status,
    'Event triggers require superuser privileges in PostgreSQL.' AS purpose,
    CASE
        WHEN current_setting('is_superuser') = 'on' THEN 'Functions and event triggers were created or replaced.'
        ELSE 'Reconnect as a superuser to enable DDL create/drop timestamp tracking.'
    END AS next_action;

SELECT
    'step_02_repository_table' AS setup_step,
    'dba_metrics.ddl_event_log' AS object_name,
    CASE WHEN to_regclass('dba_metrics.ddl_event_log') IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    'Stores DDL command and DROP event rows used by lifecycle views.' AS purpose,
    'Run DDL on a test object after enabling triggers to confirm rows are captured.' AS next_action;

SELECT
    'step_03_event_trigger_status' AS setup_step,
    trigger_name AS object_name,
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_event_trigger e WHERE e.evtname = trigger_name) THEN 'READY'
        WHEN current_setting('is_superuser') <> 'on' THEN 'SKIPPED_NOT_SUPERUSER'
        ELSE 'MISSING'
    END AS status,
    purpose,
    next_action
FROM (
    VALUES
        ('trg_dba_metrics_ddl_end', 'Captures CREATE, ALTER, and other DDL command-end events.', 'Create a test object and check dba_metrics.ddl_event_log.'),
        ('trg_dba_metrics_sql_drop', 'Captures DROP events for lifecycle/drop history.', 'Drop a test object and check dba_metrics.ddl_event_log.')
) AS t(trigger_name, purpose, next_action)
ORDER BY trigger_name;

SELECT
    'step_04_next_query' AS setup_step,
    'recent_ddl_events' AS query_name,
    'SELECT event_ts, event_kind, command_tag, object_type, schema_name, object_identity, username FROM dba_metrics.ddl_event_log ORDER BY event_ts DESC LIMIT 20;' AS sql_to_run,
    'Use this query to verify the trigger is capturing object lifecycle events.' AS purpose;


-- SAMPLE_OUTPUT_BEGIN
-- setup_step                | object_name                  | status
-- --------------------------+------------------------------+----------------------
-- step_01_superuser_check   | connected_user               | READY
-- step_02_repository_table  | dba_metrics.ddl_event_log    | READY
-- step_03_event_trigger_status | trg_dba_metrics_ddl_end   | READY
-- SAMPLE_OUTPUT_END
