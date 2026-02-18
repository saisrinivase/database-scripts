/*
Purpose: Heuristically flag large, high-write tables as partitioning candidates.
Area: Partitioning
Usage: Adjust thresholds to match your workload profile.
*/
WITH base AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        pg_total_relation_size(s.relid) AS total_bytes,
        s.n_live_tup AS estimated_live_rows,
        (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS write_volume,
        c.relispartition
    FROM pg_stat_user_tables s
    JOIN pg_class c
        ON c.oid = s.relid
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    estimated_live_rows,
    write_volume,
    CASE
        WHEN total_bytes >= 50::bigint * 1024 * 1024 * 1024 AND write_volume >= 5000000
            THEN 'Strong candidate'
        WHEN total_bytes >= 20::bigint * 1024 * 1024 * 1024 AND write_volume >= 1000000
            THEN 'Candidate'
        WHEN total_bytes >= 10::bigint * 1024 * 1024 * 1024
            THEN 'Size-only candidate'
        ELSE 'Low priority'
    END AS recommendation
FROM base
WHERE NOT relispartition
ORDER BY total_bytes DESC;
