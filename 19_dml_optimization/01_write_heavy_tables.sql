/*
Purpose: Rank tables by write volume to target DML optimization and maintenance.
Area: Optimizing Data Modification
Usage: Run before tuning autovacuum, indexing, and partition strategy.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    (n_tup_ins + n_tup_upd + n_tup_del) AS total_writes,
    n_live_tup,
    n_dead_tup,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY total_writes DESC
LIMIT 200;
