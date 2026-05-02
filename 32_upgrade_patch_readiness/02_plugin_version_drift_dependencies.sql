/*
MySQL DBA Script: Plugin Version Drift Dependencies
Purpose: Provide MySQL DBA diagnostics for plugin version drift dependencies.
Area: Upgrade Patch Readiness
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Plugin Version Drift Dependencies') AS script_name;

SELECT
    @@hostname AS host_name,
    @@port AS port,
    @@version AS server_version,
    @@version_comment AS version_comment,
    @@version_compile_machine AS compile_machine,
    @@version_compile_os AS compile_os,
    @@datadir AS data_directory,
    @@server_uuid AS server_uuid,
    @@read_only AS read_only,
    @@super_read_only AS super_read_only,
    NOW() AS captured_at;
