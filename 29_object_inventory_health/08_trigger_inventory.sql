/*
Purpose: Inventory user triggers with firing mode and trigger function binding.
Area: Object Inventory and Health
Usage: Use to detect hidden DML overhead and trigger sprawl.
*/
SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    t.tgname AS trigger_name,
    CASE t.tgenabled
        WHEN 'O' THEN 'ENABLED'
        WHEN 'D' THEN 'DISABLED'
        WHEN 'R' THEN 'ENABLED_REPLICA'
        WHEN 'A' THEN 'ENABLED_ALWAYS'
        ELSE t.tgenabled::text
    END AS trigger_status,
    pn.nspname AS function_schema,
    p.proname AS function_name,
    left(pg_get_triggerdef(t.oid, true), 300) AS trigger_definition_snippet
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_proc p ON p.oid = t.tgfoid
JOIN pg_namespace pn ON pn.oid = p.pronamespace
WHERE NOT t.tgisinternal
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY n.nspname, c.relname, t.tgname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    table_schema   |     table_name     |    trigger_name    | trigger_status | function_schema  |   function_name   |                                                                trigger_definition_snippet                                                                 
-- ------------------+--------------------+--------------------+----------------+------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
--  migration_v2_lab | trigger_audit_demo | trg_set_updated_at | ENABLED        | migration_v2_lab | fn_set_updated_at | CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON migration_v2_lab.trigger_audit_demo FOR EACH ROW EXECUTE FUNCTION migration_v2_lab.fn_set_updated_at()
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
