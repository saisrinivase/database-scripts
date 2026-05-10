/*
PostgreSQL DBA Script: Scheduler Runbook
Purpose: Provide scheduling commands for periodic snapshot capture (pg_cron or external scheduler).
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after procedures are created; choose one scheduling method.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    'step_01_capture_history' AS setup_step,
    max(captured_at) AS last_capture_ts,
    count(*) AS total_capture_runs,
    CASE WHEN count(*) = 0 THEN 'NO_CAPTURES' ELSE 'READY' END AS status,
    CASE WHEN count(*) = 0 THEN 'Run an initial capture before scheduling.' ELSE 'Capture history exists.' END AS next_action
FROM dba_metrics.capture_run;

SELECT
    'step_02_scheduler_status' AS setup_step,
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN 'PG_CRON_AVAILABLE'
        ELSE 'PG_CRON_NOT_INSTALLED'
    END AS scheduler_status,
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN 'Use pg_cron commands below or your enterprise scheduler.'
        ELSE 'Use an external scheduler or install pg_cron if approved for this environment.'
    END AS next_action;

SELECT
    'step_03_recommended_commands' AS setup_step,
    step_order,
    scheduler_type,
    command_text,
    purpose
FROM (
    VALUES
        (
            1,
            'pg_cron_15_min_capture',
            'SELECT cron.schedule(''dba_metrics_capture_15min'', ''*/15 * * * *'', $$CALL dba_metrics.sp_capture_operational_snapshot(''''pg_cron'''',''''scheduled 15m capture'''');$$);',
            'Collect frequent enough history for index usage, DML, and growth deltas.'
        ),
        (
            2,
            'pg_cron_monthly_purge',
            'SELECT cron.schedule(''dba_metrics_purge_monthly'', ''5 1 1 * *'', $$CALL dba_metrics.sp_purge_history(18);$$);',
            'Keep repository history bounded to the approved retention window.'
        ),
        (
            3,
            'external_scheduler_capture',
            'psql -d <db> -c "CALL dba_metrics.sp_capture_operational_snapshot(''''external'''',''''scheduled capture'''');"',
            'Use cron, Control-M, Jenkins, Ansible, or another approved scheduler when pg_cron is not available.'
        )
) AS c(step_order, scheduler_type, command_text, purpose)
ORDER BY step_order;

SELECT
    'step_04_validation_queries' AS setup_step,
    step_order,
    query_name,
    sql_to_run,
    purpose
FROM (
    VALUES
        (1, 'latest_capture', 'SELECT * FROM dba_metrics.capture_run ORDER BY captured_at DESC LIMIT 5;', 'Confirms scheduled captures are still running.'),
        (2, 'capture_row_counts', 'SELECT run_id, captured_at FROM dba_metrics.capture_run ORDER BY run_id DESC LIMIT 10;', 'Confirms capture cadence and recent run IDs.'),
        (3, 'monthly_capacity_report', 'Run 37_object_lifecycle_capacity/10_monthly_capacity_report.sql', 'Confirms reports have usable growth/action output.')
) AS q(step_order, query_name, sql_to_run, purpose)
ORDER BY step_order;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
--         last_capture_ts        | total_capture_runs 
-- -------------------------------+--------------------
--  2026-02-20 15:16:10.729736-05 |                 39
-- (1 row)
-- 
--    scheduler_status    |                    note                    
-- -----------------------+--------------------------------------------
--  PG_CRON_NOT_INSTALLED | Use one of the recommended commands below.
-- (1 row)
-- 
--                                                                    recommended_pg_cron_command                                                                    
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  SELECT cron.schedule('dba_metrics_capture_15min', '*/15 * * * *', $$CALL dba_metrics.sp_capture_operational_snapshot(''pg_cron'',''scheduled 15m capture'');$$);
--  SELECT cron.schedule('dba_metrics_purge_monthly', '5 1 1 * *', $$CALL dba_metrics.sp_purge_history(18);$$);
--  External scheduler example: psql -d <db> -c "CALL dba_metrics.sp_capture_operational_snapshot(''external'',''scheduled capture'');"
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
