/*
PostgreSQL DBA Script: Managed Service Fingerprint
Purpose: Infer managed-service footprint and enumerate provider-specific settings exposed in PostgreSQL.
Area: Cloud Provider Signals
Usage: Helps route troubleshooting toward provider console events when applicable.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH v AS (
    SELECT version() AS version_text
),
provider AS (
    SELECT
        CASE
            WHEN lower(version_text) LIKE '%aurora%' OR lower(version_text) LIKE '%rds%' THEN 'AWS_RDS_OR_AURORA'
            WHEN lower(version_text) LIKE '%cloud sql%' THEN 'GCP_CLOUD_SQL'
            WHEN lower(version_text) LIKE '%alloydb%' THEN 'GCP_ALLOYDB'
            WHEN lower(version_text) LIKE '%azure%' THEN 'AZURE_DATABASE_FOR_POSTGRESQL'
            ELSE 'SELF_MANAGED_OR_UNKNOWN'
        END AS provider_guess,
        version_text
    FROM v
),
provider_settings AS (
    SELECT
        name,
        setting,
        source,
        pending_restart
    FROM pg_settings
    WHERE name ~* '^(rds|aurora|cloudsql|alloydb|azure|google)'
)
SELECT
    p.provider_guess,
    p.version_text,
    (SELECT count(*) FROM provider_settings) AS provider_setting_count,
    CASE
        WHEN (SELECT count(*) FROM provider_settings) > 0 THEN 'MANAGED_SERVICE_SIGNALS_PRESENT'
        ELSE 'NO_PROVIDER_SPECIFIC_SETTINGS_DETECTED'
    END AS detection_label
FROM provider p;

SELECT
    name,
    setting,
    source,
    pending_restart
FROM pg_settings
WHERE name ~* '^(rds|aurora|cloudsql|alloydb|azure|google)'
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--      provider_guess      |                                                         version_text                                                         | provider_setting_count |            detection_label             
-- -------------------------+------------------------------------------------------------------------------------------------------------------------------+------------------------+----------------------------------------
--  SELF_MANAGED_OR_UNKNOWN | PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit |                      0 | NO_PROVIDER_SPECIFIC_SETTINGS_DETECTED
-- (1 row)
-- 
--  name | setting | source | pending_restart 
-- ------+---------+--------+-----------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END

