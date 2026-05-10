/*
PostgreSQL DBA Script: Table Modification Tracking Demo
Purpose: Demonstrate INSERT/UPDATE/DELETE delta monitoring similar to Oracle DBA_TAB_MODIFICATIONS.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after scripts 01-08. This uses dba_metrics_lab.index_demo_orders from script 11.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics_lab;

SELECT
    'step_01_lab_schema' AS demo_step,
    'dba_metrics_lab' AS object_name,
    'READY' AS status,
    'Schema for disposable table modification demo objects.' AS purpose,
    'The next step creates or reuses the demo table.' AS next_action;

CREATE TABLE IF NOT EXISTS dba_metrics_lab.index_demo_orders (
    order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id int NOT NULL,
    order_date date NOT NULL,
    status_code text NOT NULL,
    payload text
);

SELECT
    'step_02_demo_table_ready' AS demo_step,
    'dba_metrics_lab.index_demo_orders' AS object_name,
    count(*) AS starting_rows,
    pg_size_pretty(pg_total_relation_size('dba_metrics_lab.index_demo_orders')) AS table_size,
    'Demo table is ready for insert/update/delete workload.' AS purpose
FROM dba_metrics_lab.index_demo_orders;

CALL dba_metrics.sp_capture_operational_snapshot(
    'dml_demo_before',
    'Before INSERT/UPDATE/DELETE demo workload'
);

SELECT
    'step_03_before_dml_snapshot' AS demo_step,
    max(run_id) AS run_id,
    max(captured_at) AS captured_at,
    'Baseline captured before demo DML workload.' AS purpose,
    'The next steps run INSERT, UPDATE, DELETE, ANALYZE, and stats flush.' AS next_action
FROM dba_metrics.capture_run
WHERE capture_source = 'dml_demo_before';

INSERT INTO dba_metrics_lab.index_demo_orders (customer_id, order_date, status_code, payload)
SELECT
    9000 + (gs % 25),
    current_date - (gs % 30),
    'NEW',
    md5((clock_timestamp()::text || gs::text))
FROM generate_series(1, 250) AS gs;

UPDATE dba_metrics_lab.index_demo_orders
SET
    status_code = 'UPDATED',
    payload = md5(payload || '_u')
WHERE order_id IN (
    SELECT order_id
    FROM dba_metrics_lab.index_demo_orders
    ORDER BY order_id DESC
    LIMIT 180
);

DELETE FROM dba_metrics_lab.index_demo_orders
WHERE order_id IN (
    SELECT order_id
    FROM dba_metrics_lab.index_demo_orders
    ORDER BY order_id ASC
    LIMIT 90
);

SELECT
    'step_04_dml_workload_complete' AS demo_step,
    'index_demo_orders' AS table_name,
    count(*) AS ending_rows,
    'Inserted 250 rows, updated 180 recent rows, and deleted 90 oldest rows.' AS purpose,
    'Analyze and capture after-workload snapshot next.' AS next_action
FROM dba_metrics_lab.index_demo_orders;

ANALYZE dba_metrics_lab.index_demo_orders;

SELECT pg_stat_force_next_flush();

CALL dba_metrics.sp_capture_operational_snapshot(
    'dml_demo_after',
    'After INSERT/UPDATE/DELETE demo workload'
);

SELECT
    'step_05_after_dml_snapshot' AS demo_step,
    max(run_id) AS run_id,
    max(captured_at) AS captured_at,
    'Snapshot captured after demo DML workload.' AS purpose,
    'Next output shows the captured DML deltas.' AS next_action
FROM dba_metrics.capture_run
WHERE capture_source = 'dml_demo_after';

WITH latest_after AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
    WHERE capture_source = 'dml_demo_after'
)
SELECT
    'step_06_delta_result' AS demo_step,
    captured_at,
    schema_name,
    table_name,
    delta_ins,
    delta_upd,
    delta_del,
    delta_hot_upd,
    (coalesce(delta_ins, 0) + coalesce(delta_upd, 0) + coalesce(delta_del, 0)) AS total_write_delta,
    dead_tuple_pct,
    n_mod_since_analyze
FROM dba_metrics.vw_table_modification_delta
JOIN latest_after USING (run_id)
WHERE schema_name = 'dba_metrics_lab'
  AND table_name = 'index_demo_orders'
ORDER BY captured_at DESC;

SELECT
    'step_07_monthly_rollup_result' AS demo_step,
    month_start,
    schema_name,
    table_name,
    inserts,
    updates,
    deletes,
    hot_updates,
    total_dml
FROM dba_metrics.vw_table_modifications_monthly
WHERE schema_name = 'dba_metrics_lab'
  AND table_name = 'index_demo_orders'
ORDER BY month_start DESC
LIMIT 6;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE TABLE
-- CALL
-- INSERT 0 250
-- UPDATE 180
-- DELETE 90
-- ANALYZE
--  pg_stat_force_next_flush 
-- --------------------------
--  
-- (1 row)
-- 
-- CALL
--           captured_at          |   schema_name   |    table_name     | delta_ins | delta_upd | delta_del | delta_hot_upd | total_write_delta | dead_tuple_pct | n_mod_since_analyze 
-- -------------------------------+-----------------+-------------------+-----------+-----------+-----------+---------------+-------------------+----------------+---------------------
--  2026-02-20 15:16:11.776623-05 | dba_metrics_lab | index_demo_orders |       250 |       180 |        90 |             3 |               520 |           0.22 |                 520
-- (1 row)
-- 
--  month_start |   schema_name   |    table_name     | inserts | updates | deletes | hot_updates | total_dml 
-- -------------+-----------------+-------------------+---------+---------+---------+-------------+-----------
--  2026-02-01  | dba_metrics_lab | index_demo_orders |  721500 |    1080 |     540 |          33 |    723120
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
