/*
Purpose: Rank all databases by total size.
Area: Database Size
Usage: Connect to any database in the instance.
*/
SELECT
    d.datname AS database_name,
    pg_database_size(d.datname) AS size_bytes,
    pg_size_pretty(pg_database_size(d.datname)) AS size_pretty
FROM pg_database d
ORDER BY size_bytes DESC;
