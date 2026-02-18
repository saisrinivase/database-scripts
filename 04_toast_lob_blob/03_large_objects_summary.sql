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
