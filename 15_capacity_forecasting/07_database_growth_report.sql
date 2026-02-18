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
