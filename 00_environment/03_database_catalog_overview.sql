/*
Purpose: Show high-level object counts in the current database catalog.
Area: Environment / Internals
Usage: Run in any database.
*/
WITH object_counts AS (
    SELECT 'schemas'::text AS object_type, count(*)::bigint AS object_count
    FROM pg_namespace
    WHERE nspname !~ '^pg_' AND nspname <> 'information_schema'

    UNION ALL

    SELECT 'tables', count(*)
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'

    UNION ALL

    SELECT 'partitioned tables', count(*)
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'p'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'

    UNION ALL

    SELECT 'indexes', count(*)
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'i'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'

    UNION ALL

    SELECT 'views', count(*)
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'v'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT object_type, object_count
FROM object_counts
ORDER BY object_type;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

    object_type     | object_count 
--------------------+--------------
 indexes            |           43
 partitioned tables |            0
 schemas            |            4
 tables             |           34
 views              |            2
(5 rows)


SAMPLE_OUTPUT_END */
