/*
PostgreSQL DBA Script: Large Objects Summary
Purpose: Summarize large object (BLOB) footprint from pg_largeobject.
Area: TOAST / LOB / BLOB
Usage: Requires permissions to read pg_largeobject.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    count(DISTINCT loid) AS large_object_count,
    coalesce(sum(length(data)), 0) AS total_bytes,
    pg_size_pretty(coalesce(sum(length(data)), 0)::bigint) AS total_pretty
FROM pg_largeobject;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  large_object_count | total_bytes | total_pretty 
-- --------------------+-------------+--------------
--                   0 |           0 | 0 bytes
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
