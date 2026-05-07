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

WITH latest AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
)
SELECT
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
    (SELECT count(*) FROM dba_metrics.index_usage_snap i JOIN latest l ON l.run_id = i.run_id) AS index_rows,
    (SELECT count(*) FROM dba_metrics.table_mod_snap t JOIN latest l ON l.run_id = t.run_id) AS table_rows,
    (SELECT count(*) FROM dba_metrics.object_size_snap o JOIN latest l ON l.run_id = o.run_id) AS object_rows,
    (SELECT count(*) FROM dba_metrics.tablespace_size_snap s JOIN latest l ON l.run_id = s.run_id) AS tablespace_rows;


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
