/*
Purpose: Demo index lifecycle by creating indexes, forcing index scans, and dropping an unused index.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run after scripts 01-08; this creates objects in schema dba_metrics_lab.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics_lab;

DROP TABLE IF EXISTS dba_metrics_lab.index_demo_orders;

CREATE TABLE dba_metrics_lab.index_demo_orders (
    order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id int NOT NULL,
    order_date date NOT NULL,
    status_code text NOT NULL,
    payload text
);

INSERT INTO dba_metrics_lab.index_demo_orders (customer_id, order_date, status_code, payload)
SELECT
    (100 + (gs % 5000))::int,
    current_date - (gs % 365),
    CASE WHEN gs % 10 = 0 THEN 'HOLD' WHEN gs % 3 = 0 THEN 'PENDING' ELSE 'COMPLETE' END,
    md5(gs::text)
FROM generate_series(1, 120000) AS gs;

DROP INDEX IF EXISTS dba_metrics_lab.idx_demo_orders_customer;
DROP INDEX IF EXISTS dba_metrics_lab.idx_demo_orders_status_payload;

CREATE INDEX idx_demo_orders_customer
    ON dba_metrics_lab.index_demo_orders (customer_id);

CREATE INDEX idx_demo_orders_status_payload
    ON dba_metrics_lab.index_demo_orders (status_code, payload);

CALL dba_metrics.sp_capture_operational_snapshot(
    'demo_before_use',
    'Before running index-using queries in lab'
);

SET enable_seqscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM dba_metrics_lab.index_demo_orders
WHERE customer_id BETWEEN 120 AND 900;

SELECT count(*)
FROM dba_metrics_lab.index_demo_orders
WHERE customer_id BETWEEN 120 AND 900;

SELECT count(*)
FROM dba_metrics_lab.index_demo_orders
WHERE customer_id = 777;

SELECT count(*)
FROM dba_metrics_lab.index_demo_orders
WHERE customer_id IN (333, 777, 999);

RESET enable_seqscan;

CALL dba_metrics.sp_capture_operational_snapshot(
    'demo_after_use',
    'After running index-using queries in lab'
);

DROP INDEX dba_metrics_lab.idx_demo_orders_status_payload;

CALL dba_metrics.sp_capture_operational_snapshot(
    'demo_after_drop',
    'After dropping unused demo index'
);

SELECT
    schema_name,
    table_name,
    index_name,
    current_idx_scan,
    first_seen_at,
    last_scan_at,
    dropped_at,
    lifecycle_status,
    advisory_note
FROM dba_metrics.vw_index_lifecycle
WHERE schema_name = 'dba_metrics_lab'
   OR index_name = 'idx_demo_orders_status_payload'
ORDER BY index_name, dropped_at NULLS FIRST;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- DROP TABLE
-- CREATE TABLE
-- INSERT 0 120000
-- DROP INDEX
-- DROP INDEX
-- CREATE INDEX
-- CREATE INDEX
-- CALL
-- SET
--                                                                    QUERY PLAN                                                                    
-- -------------------------------------------------------------------------------------------------------------------------------------------------
--  Aggregate  (cost=1096.28..1096.29 rows=1 width=8) (actual time=1.283..1.283 rows=1.00 loops=1)
--    Buffers: shared hit=234 read=19
--    ->  Bitmap Heap Scan on index_demo_orders  (cost=10.44..1094.78 rows=600 width=0) (actual time=0.226..0.924 rows=18744.00 loops=1)
--          Recheck Cond: ((customer_id >= 120) AND (customer_id <= 900))
--          Heap Blocks: exact=234
--          Buffers: shared hit=234 read=19
--          ->  Bitmap Index Scan on idx_demo_orders_customer  (cost=0.00..10.29 rows=600 width=0) (actual time=0.212..0.212 rows=18744.00 loops=1)
--                Index Cond: ((customer_id >= 120) AND (customer_id <= 900))
--                Index Searches: 1
--                Buffers: shared read=19
--  Planning:
--    Buffers: shared hit=11 read=2
--  Planning Time: 0.094 ms
--  Execution Time: 1.288 ms
-- (14 rows)
-- 
--  count 
-- -------
--  18744
-- (1 row)
-- 
--  count 
-- -------
--     24
-- (1 row)
-- 
--  count 
-- -------
--     72
-- (1 row)
-- 
-- RESET
-- CALL
-- DROP INDEX
-- CALL
--    schema_name   |    table_name     |           index_name           | current_idx_scan |        first_seen_at         |         last_scan_at          |          dropped_at           |   lifecycle_status    |                               advisory_note                               
-- -----------------+-------------------+--------------------------------+------------------+------------------------------+-------------------------------+-------------------------------+-----------------------+---------------------------------------------------------------------------
--  dba_metrics_lab | index_demo_orders | idx_demo_orders_customer       |                0 | 2026-02-20 14:51:40.51019-05 | 2026-02-20 15:15:23.600605-05 |                               | ACTIVE                | No immediate action.
--  dba_metrics_lab | index_demo_orders | idx_demo_orders_status_payload |                0 | 2026-02-20 14:51:40.51019-05 |                               | 2026-02-20 15:16:11.627718-05 | DROPPED_EVENT_PRESENT | Drop event exists for index name currently present; review event history.
--  dba_metrics_lab | index_demo_orders | index_demo_orders_pkey         |                0 | 2026-02-20 14:51:40.51019-05 | 2026-02-20 15:15:23.709467-05 |                               | ACTIVE                | Protected: primary key index. Do not drop.
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
