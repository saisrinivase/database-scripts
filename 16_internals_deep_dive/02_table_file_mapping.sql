/*
MySQL DBA Script: Table File Mapping
Purpose: Provide MySQL DBA diagnostics for table file mapping.
Area: Internals Deep Dive
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Table File Mapping') AS script_name;

SELECT name, space, row_format, space_type, file_format, zip_page_size, server_version, state
FROM information_schema.innodb_tablespaces
ORDER BY name;
