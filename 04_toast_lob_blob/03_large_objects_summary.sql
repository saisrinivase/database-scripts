/*
Purpose: Summarize large object (BLOB) footprint from pg_largeobject.
Area: TOAST / LOB / BLOB
Usage: Requires permissions to read pg_largeobject.
*/
SELECT
    count(DISTINCT loid) AS large_object_count,
    coalesce(sum(length(data)), 0) AS total_bytes,
    pg_size_pretty(coalesce(sum(length(data)), 0)::bigint) AS total_pretty
FROM pg_largeobject;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 large_object_count | total_bytes | total_pretty 
--------------------+-------------+--------------
                  0 |           0 | 0 bytes
(1 row)


SAMPLE_OUTPUT_END */
