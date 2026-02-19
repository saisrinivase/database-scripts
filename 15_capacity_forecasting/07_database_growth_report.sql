/*
Purpose: Report database growth between first and latest snapshots in repository.
Area: Capacity Forecasting
Usage: Requires captured data in dba_metrics.database_size_snapshots.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

           database_name           |       first_captured_at       |       last_captured_at        | first_size_bytes | last_size_bytes | growth_bytes | growth_pretty | growth_bytes_per_second 
-----------------------------------+-------------------------------+-------------------------------+------------------+-----------------+--------------+---------------+-------------------------
 script_validation_20260218_172749 | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |        436508351 |       468506303 |     31997952 | 31 MB         |                36720.43
 postgres                          | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |          8140479 |        40007359 |     31866880 | 30 MB         |                36570.02
 appdb                             | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |          8050367 |         8066751 |        16384 | 16 kB         |                   18.80
 template1                         | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |          8033983 |         8033983 |            0 | 0 bytes       |                    0.00
 pgbench_test                      | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |      32018454207 |     32018454207 |            0 | 0 bytes       |                    0.00
 hypopg_lab                        | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |         36173503 |        36173503 |            0 | 0 bytes       |                    0.00
 perf_test                         | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:43:13.214519-05 |        436410047 |       436410047 |            0 | 0 bytes       |                    0.00
(7 rows)


SAMPLE_OUTPUT_END */
