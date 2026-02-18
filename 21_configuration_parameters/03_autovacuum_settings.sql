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
