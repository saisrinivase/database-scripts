/*
PostgreSQL DBA Script: Hot Update Efficiency
Purpose: Evaluate HOT update efficiency (lower ratio may indicate index churn and write amplification).
Area: Optimizing Data Modification
Usage: Focus on heavily updated tables.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_tup_upd,
    n_tup_hot_upd,
    CASE
        WHEN n_tup_upd = 0 THEN NULL
        ELSE round(100.0 * n_tup_hot_upd / n_tup_upd, 2)
    END AS hot_update_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE n_tup_upd > 0
ORDER BY hot_update_pct ASC NULLS LAST, n_tup_upd DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | n_tup_upd | n_tup_hot_upd | hot_update_pct | total_size 
-- ------------------+-------------------------+-----------+---------------+----------------+------------
--  migration_v2_lab | amount_mapping_risk     |    120000 |             0 |           0.00 | 19 MB
--  migration_v2_lab | customer_contact_compat |     51429 |           466 |           0.91 | 13 MB
--  public           | pgbench_accounts        |   5332823 |       2672081 |          50.11 | 30 GB
--  public           | pgbench_tellers         |   5332823 |       5288199 |          99.16 | 3712 kB
--  public           | pgbench_branches        |   5332823 |       5316334 |          99.69 | 7048 kB
-- (5 rows)
-- 
-- SAMPLE_OUTPUT_END
