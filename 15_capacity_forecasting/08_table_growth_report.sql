/*
Purpose: Report top table growth between first and latest repository snapshots.
Area: Capacity Forecasting
Usage: Requires captured data in dba_metrics.table_size_snapshots.
*/
WITH ranked AS (
    SELECT
        schema_name,
        table_name,
        captured_at,
        total_bytes,
        row_number() OVER (PARTITION BY schema_name, table_name ORDER BY captured_at ASC) AS rn_first,
        row_number() OVER (PARTITION BY schema_name, table_name ORDER BY captured_at DESC) AS rn_last
    FROM dba_metrics.table_size_snapshots
),
first_snap AS (
    SELECT schema_name, table_name, captured_at AS first_captured_at, total_bytes AS first_bytes
    FROM ranked
    WHERE rn_first = 1
),
last_snap AS (
    SELECT schema_name, table_name, captured_at AS last_captured_at, total_bytes AS last_bytes
    FROM ranked
    WHERE rn_last = 1
)
SELECT
    l.schema_name,
    l.table_name,
    f.first_captured_at,
    l.last_captured_at,
    f.first_bytes,
    l.last_bytes,
    (l.last_bytes - f.first_bytes) AS growth_bytes,
    pg_size_pretty((l.last_bytes - f.first_bytes)::bigint) AS growth_pretty
FROM last_snap l
JOIN first_snap f
    ON f.schema_name = l.schema_name
   AND f.table_name = l.table_name
ORDER BY growth_bytes DESC
LIMIT 200;
