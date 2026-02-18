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
