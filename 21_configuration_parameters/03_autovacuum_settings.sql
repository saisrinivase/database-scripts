/*
Purpose: Report autovacuum and freeze-related settings.
Area: Configuration Parameters
Usage: Review when dead tuples, bloat, or xid age rise.
*/
SELECT
    name,
    setting,
    unit,
    source
FROM pg_settings
WHERE name IN (
    'autovacuum',
    'autovacuum_max_workers',
    'autovacuum_naptime',
    'autovacuum_vacuum_threshold',
    'autovacuum_vacuum_scale_factor',
    'autovacuum_analyze_threshold',
    'autovacuum_analyze_scale_factor',
    'autovacuum_freeze_max_age',
    'vacuum_freeze_table_age',
    'vacuum_freeze_min_age'
)
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--               name               |  setting  | unit | source  
-- ---------------------------------+-----------+------+---------
--  autovacuum                      | on        |      | default
--  autovacuum_analyze_scale_factor | 0.1       |      | default
--  autovacuum_analyze_threshold    | 50        |      | default
--  autovacuum_freeze_max_age       | 200000000 |      | default
--  autovacuum_max_workers          | 3         |      | default
--  autovacuum_naptime              | 60        | s    | default
--  autovacuum_vacuum_scale_factor  | 0.2       |      | default
--  autovacuum_vacuum_threshold     | 50        |      | default
--  vacuum_freeze_min_age           | 50000000  |      | default
--  vacuum_freeze_table_age         | 150000000 |      | default
-- (10 rows)
-- 
-- SAMPLE_OUTPUT_END
