/*
Purpose: List trigger functions and their table bindings.
Area: Functions and Dynamic SQL
Usage: Heavy trigger paths can dominate DML latency.
*/
SELECT
    tn.nspname AS table_schema,
    tc.relname AS table_name,
    t.tgname AS trigger_name,
    fn.nspname AS function_schema,
    p.proname AS function_name,
    t.tgenabled,
    pg_get_triggerdef(t.oid, true) AS trigger_def
FROM pg_trigger t
JOIN pg_class tc
    ON tc.oid = t.tgrelid
JOIN pg_namespace tn
    ON tn.oid = tc.relnamespace
JOIN pg_proc p
    ON p.oid = t.tgfoid
JOIN pg_namespace fn
    ON fn.oid = p.pronamespace
WHERE NOT t.tgisinternal
  AND tn.nspname !~ '^pg_'
  AND tn.nspname <> 'information_schema'
ORDER BY table_schema, table_name, trigger_name;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 table_schema | table_name | trigger_name | function_schema | function_name | tgenabled | trigger_def 
--------------+------------+--------------+-----------------+---------------+-----------+-------------
(0 rows)


SAMPLE_OUTPUT_END */
