/*
PostgreSQL DBA Script: Missing Index Candidates From Scan Pressure
Purpose: Detect large tables with heavy sequential scan pressure as index candidate hotspots.
Area: High Speed Tuning
Usage: Review query predicates before creating indexes; this script finds tables, not exact columns.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH io AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        s.seq_scan,
        s.idx_scan,
        st.heap_blks_read,
        st.heap_blks_hit,
        pg_total_relation_size(s.relid) AS total_bytes,
        s.n_live_tup
    FROM pg_stat_user_tables s
    JOIN pg_statio_user_tables st
        ON st.relid = s.relid
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    n_live_tup AS estimated_live_rows,
    seq_scan,
    idx_scan,
    round(100.0 * seq_scan / NULLIF(seq_scan + idx_scan, 0), 2) AS seq_scan_pct,
    heap_blks_read,
    heap_blks_hit,
    CASE
        WHEN seq_scan >= 5000 AND total_bytes >= 1024::bigint * 1024 * 1024 THEN 'High-priority index review'
        WHEN seq_scan >= 1000 AND total_bytes >= 256::bigint * 1024 * 1024 THEN 'Index review candidate'
        ELSE 'Observe'
    END AS recommendation,
    format('-- Template: CREATE INDEX CONCURRENTLY ON %I.%I (<predicate_columns>);', schema_name, table_name) AS index_template
FROM io
WHERE total_bytes >= 128::bigint * 1024 * 1024
ORDER BY seq_scan_pct DESC NULLS LAST, heap_blks_read DESC, total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | total_bytes | total_pretty | estimated_live_rows | seq_scan | idx_scan | seq_scan_pct | heap_blks_read | heap_blks_hit | recommendation |                                      index_template                                      
-- -------------+------------------+-------------+--------------+---------------------+----------+----------+--------------+----------------+---------------+----------------+------------------------------------------------------------------------------------------
--  public      | pgbench_accounts | 31716564992 | 30 GB        |           200000029 |        2 | 10665646 |         0.00 |        8716689 |      30324707 | Observe        | -- Template: CREATE INDEX CONCURRENTLY ON public.pgbench_accounts (<predicate_columns>);
--  public      | pgbench_history  |   282656768 | 270 MB       |             5331130 |        0 |          |              |         189340 |       5565865 | Observe        | -- Template: CREATE INDEX CONCURRENTLY ON public.pgbench_history (<predicate_columns>);
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
