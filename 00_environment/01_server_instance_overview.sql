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
