/*
Purpose: Evaluate HOT update efficiency (lower ratio may indicate index churn and write amplification).
Area: Optimizing Data Modification
Usage: Focus on heavily updated tables.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name | table_name | n_tup_upd | n_tup_hot_upd | hot_update_pct | total_size 
-------------+------------+-----------+---------------+----------------+------------
(0 rows)


SAMPLE_OUTPUT_END */
