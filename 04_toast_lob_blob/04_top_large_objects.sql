/*
Purpose: Rank largest individual large objects (BLOBs) by size.
Area: TOAST / LOB / BLOB
Usage: Use with caution on very large catalogs.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 loid | large_object_bytes | large_object_pretty | chunk_count 
------+--------------------+---------------------+-------------
(0 rows)


SAMPLE_OUTPUT_END */
