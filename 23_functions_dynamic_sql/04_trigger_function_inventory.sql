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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    table_schema   |     table_name     |    trigger_name    | function_schema  |   function_name   | tgenabled |                                                                        trigger_def                                                                        
-- ------------------+--------------------+--------------------+------------------+-------------------+-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  migration_v2_lab | trigger_audit_demo | trg_set_updated_at | migration_v2_lab | fn_set_updated_at | O         | CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON migration_v2_lab.trigger_audit_demo FOR EACH ROW EXECUTE FUNCTION migration_v2_lab.fn_set_updated_at()
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
