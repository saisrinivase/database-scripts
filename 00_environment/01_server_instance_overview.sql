/*
Purpose: Provide a quick PostgreSQL instance fingerprint for troubleshooting.
Area: Environment / Internals
Usage: Run in any database.
*/
SELECT
    current_database() AS database_name,
    current_user AS login_role,
    version() AS server_version,
    current_setting('server_version_num') AS server_version_num,
    pg_postmaster_start_time() AS postmaster_start_time,
    now() - pg_postmaster_start_time() AS instance_uptime,
    current_setting('data_directory') AS data_directory,
    current_setting('config_file') AS config_file,
    current_setting('hba_file') AS hba_file;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  database_name | login_role |                                                        server_version                                                        | server_version_num |     postmaster_start_time     |    instance_uptime     |         data_directory          |                   config_file                   |                  hba_file                   
-- ---------------+------------+------------------------------------------------------------------------------------------------------------------------------+--------------------+-------------------------------+------------------------+---------------------------------+-------------------------------------------------+---------------------------------------------
--  pgbench_test  | saiendla   | PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit | 180000             | 2026-02-10 09:32:09.191307-05 | 8 days 10:11:21.746752 | /opt/homebrew/var/postgresql@18 | /opt/homebrew/var/postgresql@18/postgresql.conf | /opt/homebrew/var/postgresql@18/pg_hba.conf
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END

