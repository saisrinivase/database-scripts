/*
PostgreSQL DBA Script: Instance Platform Fingerprint
Purpose: Capture platform hints and runtime footprint for physical/cloud diagnosis.
Area: Physical and Cloud Diagnostics
Usage: Baseline script for environment-aware tuning.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--                                                         version_string                                                        | server_version_num |         data_directory          |                   config_file                   |                  hba_file                   |     postmaster_start_time     |         uptime         |              platform_hint              
-- ------------------------------------------------------------------------------------------------------------------------------+--------------------+---------------------------------+-------------------------------------------------+---------------------------------------------+-------------------------------+------------------------+-----------------------------------------
--  PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit | 180000             | /opt/homebrew/var/postgresql@18 | /opt/homebrew/var/postgresql@18/postgresql.conf | /opt/homebrew/var/postgresql@18/pg_hba.conf | 2026-02-10 09:32:09.191307-05 | 8 days 10:11:23.880213 | Self-managed or unknown managed service
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END

