/*
PostgreSQL DBA Script: Database Growth Report
Purpose: Report database growth between first and latest snapshots in repository.
Area: Capacity Forecasting
Usage: Requires captured data in dba_metrics.database_size_snapshots.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH ranked AS (
    SELECT
        database_name,
        captured_at,
        size_bytes,
        row_number() OVER (PARTITION BY database_name ORDER BY captured_at ASC) AS rn_first,
        row_number() OVER (PARTITION BY database_name ORDER BY captured_at DESC) AS rn_last
    FROM dba_metrics.database_size_snapshots
),
first_snap AS (
    SELECT database_name, captured_at AS first_captured_at, size_bytes AS first_size_bytes
    FROM ranked
    WHERE rn_first = 1
),
last_snap AS (
    SELECT database_name, captured_at AS last_captured_at, size_bytes AS last_size_bytes
    FROM ranked
    WHERE rn_last = 1
)
SELECT
    l.database_name,
    f.first_captured_at,
    l.last_captured_at,
    f.first_size_bytes,
    l.last_size_bytes,
    (l.last_size_bytes - f.first_size_bytes) AS growth_bytes,
    pg_size_pretty((l.last_size_bytes - f.first_size_bytes)::bigint) AS growth_pretty,
    CASE
        WHEN extract(epoch FROM (l.last_captured_at - f.first_captured_at)) > 0
            THEN ((l.last_size_bytes - f.first_size_bytes) / extract(epoch FROM (l.last_captured_at - f.first_captured_at)))::numeric(20,2)
        ELSE NULL
    END AS growth_bytes_per_second
FROM last_snap l
JOIN first_snap f
    ON f.database_name = l.database_name
ORDER BY growth_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           |       first_captured_at       |       last_captured_at        | first_size_bytes | last_size_bytes | growth_bytes | growth_pretty | growth_bytes_per_second 
-- -----------------------------------+-------------------------------+-------------------------------+------------------+-----------------+--------------+---------------+-------------------------
--  pgbench_test                      | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |      32205059775 |     32236762815 |     31703040 | 30 MB         |               147650.80
--  hypopg_lab                        | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |         36173503 |        36173503 |            0 | 0 bytes       |                    0.00
--  perf_test                         | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |        436410047 |       436410047 |            0 | 0 bytes       |                    0.00
--  appdb                             | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |          8058559 |         8058559 |            0 | 0 bytes       |                    0.00
--  postgres                          | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |         40007359 |        40007359 |            0 | 0 bytes       |                    0.00
--  script_validation_20260218_172749 | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |        468563647 |       468563647 |            0 | 0 bytes       |                    0.00
--  template1                         | 2026-02-18 19:39:57.460654-05 | 2026-02-18 19:43:32.176999-05 |          8033983 |         8033983 |            0 | 0 bytes       |                    0.00
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END
