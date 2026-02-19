/*
Purpose: Identify user tables without primary keys.
Area: Design Matters
Usage: Missing PKs often hurt data integrity and query/index design.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_constraint con
    ON con.conrelid = c.oid
   AND con.contype = 'p'
WHERE c.relkind = 'r'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND con.oid IS NULL
ORDER BY pg_total_relation_size(c.oid) DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name |       table_name        | total_size 
-------------+-------------------------+------------
 dba_metrics | index_size_snapshots    | 64 kB
 dba_metrics | table_size_snapshots    | 56 kB
 dba_metrics | connection_snapshots    | 16 kB
 dba_metrics | database_size_snapshots | 16 kB
 dba_metrics | wal_snapshots           | 16 kB
(5 rows)


SAMPLE_OUTPUT_END */
