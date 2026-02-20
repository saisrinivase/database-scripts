/*
Purpose: Provide scheduling commands for periodic snapshot capture (pg_cron or external scheduler).
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after procedures are created; choose one scheduling method.
*/
SELECT
    max(captured_at) AS last_capture_ts,
    count(*) AS total_capture_runs
FROM dba_metrics.capture_run;

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN 'PG_CRON_AVAILABLE'
        ELSE 'PG_CRON_NOT_INSTALLED'
    END AS scheduler_status,
    'Use one of the recommended commands below.' AS note;

SELECT
    'SELECT cron.schedule(''dba_metrics_capture_15min'', ''*/15 * * * *'', $$CALL dba_metrics.sp_capture_operational_snapshot(''''pg_cron'''',''''scheduled 15m capture'''');$$);' AS recommended_pg_cron_command
UNION ALL
SELECT
    'SELECT cron.schedule(''dba_metrics_purge_monthly'', ''5 1 1 * *'', $$CALL dba_metrics.sp_purge_history(18);$$);'
UNION ALL
SELECT
    'External scheduler example: psql -d <db> -c "CALL dba_metrics.sp_capture_operational_snapshot(''''external'''',''''scheduled capture'''');"';


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
