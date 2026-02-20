/*
Purpose: Demonstrate INSERT/UPDATE/DELETE delta monitoring similar to Oracle DBA_TAB_MODIFICATIONS.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after scripts 01-08. This uses dba_metrics_lab.index_demo_orders from script 11.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics_lab;

CREATE TABLE IF NOT EXISTS dba_metrics_lab.index_demo_orders (
    order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id int NOT NULL,
    order_date date NOT NULL,
    status_code text NOT NULL,
    payload text
);

CALL dba_metrics.sp_capture_operational_snapshot(
    'dml_demo_before',
    'Before INSERT/UPDATE/DELETE demo workload'
);

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

ANALYZE dba_metrics_lab.index_demo_orders;

SELECT pg_stat_force_next_flush();

CALL dba_metrics.sp_capture_operational_snapshot(
    'dml_demo_after',
    'After INSERT/UPDATE/DELETE demo workload'
);

WITH latest_after AS (
    SELECT max(run_id) AS run_id
    FROM dba_metrics.capture_run
    WHERE capture_source = 'dml_demo_after'
)
SELECT
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
