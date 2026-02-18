/*
Purpose: Capture platform hints and runtime footprint for physical/cloud diagnosis.
Area: Physical and Cloud Diagnostics
Usage: Baseline script for environment-aware tuning.
*/
SELECT
    version() AS version_string,
    current_setting('server_version_num') AS server_version_num,
    current_setting('data_directory') AS data_directory,
    current_setting('config_file') AS config_file,
    current_setting('hba_file') AS hba_file,
    pg_postmaster_start_time() AS postmaster_start_time,
    now() - pg_postmaster_start_time() AS uptime,
    CASE
        WHEN version() ILIKE '%aurora%' THEN 'AWS Aurora PostgreSQL hint'
        WHEN version() ILIKE '%rds%' THEN 'AWS RDS PostgreSQL hint'
        WHEN version() ILIKE '%cloud sql%' THEN 'GCP Cloud SQL hint'
        WHEN version() ILIKE '%azure%' THEN 'Azure PostgreSQL hint'
        ELSE 'Self-managed or unknown managed service'
    END AS platform_hint;
