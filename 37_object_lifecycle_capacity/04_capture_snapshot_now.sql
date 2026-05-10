/*
PostgreSQL DBA Script: Capture Snapshot Now
Purpose: Capture an immediate snapshot for index/table/object lifecycle baselining.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run once after setup, then schedule periodic execution.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CALL dba_metrics.sp_capture_operational_snapshot(
    'manual',
    'bootstrap capture'
);

SELECT
    'step_01_capture_call' AS setup_step,
    'dba_metrics.sp_capture_operational_snapshot' AS object_name,
    'COMPLETED' AS status,
    'Executed the snapshot procedure for the current database.' AS purpose,
    'Review the following result sets to confirm row counts were captured.' AS next_action;

WITH latest AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
)
SELECT
    'step_02_latest_capture' AS setup_step,
    r.run_id,
    r.captured_at,
    r.database_name,
    r.capture_source,
    r.notes
FROM dba_metrics.capture_run r
JOIN latest l
  ON l.run_id = r.run_id;

WITH latest AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
)
SELECT
    'step_03_snapshot_row_counts' AS setup_step,
    (SELECT count(*) FROM dba_metrics.index_usage_snap i JOIN latest l ON l.run_id = i.run_id) AS index_rows,
    (SELECT count(*) FROM dba_metrics.table_mod_snap t JOIN latest l ON l.run_id = t.run_id) AS table_rows,
    (SELECT count(*) FROM dba_metrics.object_size_snap o JOIN latest l ON l.run_id = o.run_id) AS object_rows,
    (SELECT count(*) FROM dba_metrics.tablespace_size_snap s JOIN latest l ON l.run_id = s.run_id) AS tablespace_rows;

WITH latest AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
)
SELECT
    'step_04_capture_interpretation' AS setup_step,
    CASE
        WHEN (SELECT count(*) FROM dba_metrics.object_size_snap o JOIN latest l ON l.run_id = o.run_id) > 0 THEN 'READY'
        ELSE 'NO_OBJECT_ROWS'
    END AS status,
    'A healthy capture usually has rows in index, table, object, database, tablespace, and stats reset snapshot tables.' AS purpose,
    CASE
        WHEN (SELECT count(*) FROM dba_metrics.object_size_snap o JOIN latest l ON l.run_id = o.run_id) > 0 THEN 'Create or refresh reporting views, then run the monthly capacity report.'
        ELSE 'Confirm repository tables exist and the connected database has user objects visible to this role.'
    END AS next_action;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CALL
--  run_id |          captured_at          | database_name | capture_source |       notes       
-- --------+-------------------------------+---------------+----------------+-------------------
--      40 | 2026-02-20 15:16:10.729736-05 | pgbench_test  | manual         | bootstrap capture
-- (1 row)
-- 
--  index_rows | table_rows | object_rows | tablespace_rows 
-- ------------+------------+-------------+-----------------
--          51 |         46 |         119 |               2
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
