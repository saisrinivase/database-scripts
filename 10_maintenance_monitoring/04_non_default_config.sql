/*
Purpose: List configuration parameters that differ from built-in defaults.
Area: Maintenance and Monitoring
Usage: Good baseline for environment drift checks.
*/
SELECT
    name,
    setting,
    unit,
    source,
    boot_val,
    reset_val
FROM pg_settings
WHERE source <> 'default'
ORDER BY name;
