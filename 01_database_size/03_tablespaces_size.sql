/*
Purpose: Show tablespace usage to identify storage pressure by tablespace.
Area: Database Size
Usage: Run as role with access to tablespace stats.
*/
SELECT
    spcname AS tablespace_name,
    pg_tablespace_size(oid) AS size_bytes,
    pg_size_pretty(pg_tablespace_size(oid)) AS size_pretty
FROM pg_tablespace
ORDER BY size_bytes DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 tablespace_name | size_bytes  | size_pretty 
-----------------+-------------+-------------
 pg_default      | 33023539496 | 31 GB
 pg_global       |      586116 | 572 kB
(2 rows)


SAMPLE_OUTPUT_END */
