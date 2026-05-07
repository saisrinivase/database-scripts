/*
PostgreSQL DBA Script: Top Large Objects
Purpose: Rank largest individual large objects (BLOBs) by size.
Area: TOAST / LOB / BLOB
Usage: Use with caution on very large catalogs.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    loid,
    sum(length(data)) AS large_object_bytes,
    pg_size_pretty(sum(length(data))::bigint) AS large_object_pretty,
    count(*) AS chunk_count
FROM pg_largeobject
GROUP BY loid
ORDER BY large_object_bytes DESC
LIMIT 100;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  loid | large_object_bytes | large_object_pretty | chunk_count 
-- ------+--------------------+---------------------+-------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No large object rows were found in this capture.
-- - This means pg_largeobject currently has no user large objects, or access is restricted.
-- SAMPLE_OUTPUT_END
