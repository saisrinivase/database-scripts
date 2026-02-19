/*
Purpose: Show backend process distribution by backend_type.
Area: Connection and Workload
Usage: Distinguish client backends from maintenance/background workers.
*/
SELECT
    backend_type,
    count(*) AS backend_count
FROM pg_stat_activity
GROUP BY backend_type
ORDER BY backend_count DESC, backend_type;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

         backend_type         | backend_count 
------------------------------+---------------
 client backend               |             4
 io worker                    |             3
 autovacuum launcher          |             1
 background writer            |             1
 checkpointer                 |             1
 logical replication launcher |             1
 walwriter                    |             1
(7 rows)


SAMPLE_OUTPUT_END */
