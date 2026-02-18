/*
Purpose: Heuristically flag wide, high-write tables lacking extended statistics objects.
Area: Planner and Statistics
Usage: Candidate list for CREATE STATISTICS (dependencies, ndistinct, mcv).
*/
WITH table_profile AS (
    SELECT
        c.oid AS relid,
        n.nspname AS schema_name,
        c.relname AS table_name,
        count(a.attnum) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS column_count,
        coalesce(s.n_tup_ins + s.n_tup_upd + s.n_tup_del, 0) AS write_volume,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    JOIN pg_attribute a
        ON a.attrelid = c.oid
    LEFT JOIN pg_stat_user_tables s
        ON s.relid = c.oid
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY c.oid, n.nspname, c.relname, s.n_tup_ins, s.n_tup_upd, s.n_tup_del
),
ext_stats AS (
    SELECT stxrelid AS relid, count(*) AS ext_stats_count
    FROM pg_statistic_ext
    GROUP BY stxrelid
)
SELECT
    t.schema_name,
    t.table_name,
    t.column_count,
    t.write_volume,
    t.total_bytes,
    pg_size_pretty(t.total_bytes) AS total_pretty,
    coalesce(e.ext_stats_count, 0) AS ext_stats_count,
    CASE
        WHEN t.column_count >= 15 AND t.write_volume >= 100000 AND coalesce(e.ext_stats_count, 0) = 0 THEN 'Candidate'
        WHEN t.column_count >= 25 AND coalesce(e.ext_stats_count, 0) = 0 THEN 'Candidate'
        ELSE 'Observe'
    END AS recommendation
FROM table_profile t
LEFT JOIN ext_stats e
    ON e.relid = t.relid
ORDER BY t.total_bytes DESC;
