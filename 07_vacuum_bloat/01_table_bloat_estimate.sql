/*
PostgreSQL DBA Script: Table Bloat Estimate
Purpose: Approximate per-table bloat impact using dead tuple density.
Area: Vacuum and Bloat
Usage: Heuristic estimate; validate with deeper tooling for exact bloat.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH stats AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        s.n_live_tup,
        s.n_dead_tup,
        pg_total_relation_size(s.relid) AS total_bytes
    FROM pg_stat_user_tables s
),
bloat AS (
    SELECT
        schema_name,
        table_name,
        total_bytes,
        n_live_tup,
        n_dead_tup,
        round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
        (n_dead_tup * (total_bytes / NULLIF(n_live_tup + n_dead_tup, 0)))::bigint AS est_bloat_bytes
    FROM stats
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    n_live_tup,
    n_dead_tup,
    dead_tuple_pct,
    est_bloat_bytes,
    pg_size_pretty(est_bloat_bytes) AS est_bloat_pretty,
    round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) AS est_bloat_pct_of_table,
    CASE
        WHEN est_bloat_bytes >= 10::bigint * 1024 * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 30
                 AND total_bytes >= 1024::bigint * 1024 * 1024
             )
            THEN 'CRITICAL'
        WHEN est_bloat_bytes >= 1024::bigint * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 20
                 AND total_bytes >= 256::bigint * 1024 * 1024
             )
            THEN 'HIGH'
        WHEN est_bloat_bytes >= 256::bigint * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 10
                 AND total_bytes >= 64::bigint * 1024 * 1024
             )
            THEN 'MEDIUM'
        ELSE 'LOW'
    END AS bloat_severity,
    CASE
        WHEN est_bloat_bytes >= 10::bigint * 1024 * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 30
                 AND total_bytes >= 1024::bigint * 1024 * 1024
             )
            THEN 'Immediate action: check blockers/long transactions, run VACUUM, and plan pg_repack or VACUUM FULL during maintenance if space must be reclaimed.'
        WHEN est_bloat_bytes >= 1024::bigint * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 20
                 AND total_bytes >= 256::bigint * 1024 * 1024
             )
            THEN 'Prioritize cleanup: review autovacuum thresholds, dead tuple growth, long transactions, and schedule table maintenance.'
        WHEN est_bloat_bytes >= 256::bigint * 1024 * 1024
             OR (
                 round(100.0 * est_bloat_bytes / NULLIF(total_bytes, 0), 2) >= 10
                 AND total_bytes >= 64::bigint * 1024 * 1024
             )
            THEN 'Monitor closely: confirm autovacuum is keeping up and check for update/delete hot spots.'
        ELSE 'Low estimated bloat: no immediate action unless table is latency critical or growing quickly.'
    END AS recommended_action
FROM bloat
WHERE n_dead_tup > 0
ORDER BY est_bloat_bytes DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | total_pretty | n_live_tup | n_dead_tup | dead_tuple_pct | est_bloat_pretty | est_bloat_pct_of_table | bloat_severity | recommended_action
-- -------------+------------------+--------------+------------+------------+----------------+-------------------+------------------------+----------------+------------------------------
--  public      | pgbench_accounts | 30 GB        |  200000029 |    4232485 |           2.07 | 626 MB            |                   2.07 | MEDIUM         | Monitor closely...
--  public      | pgbench_branches | 7048 kB      |       2000 |         81 |           3.89 | 274 kB            |                   3.89 | LOW            | Low estimated bloat...
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
