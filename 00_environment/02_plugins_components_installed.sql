/*
MySQL DBA Script: Plugins Components Installed
Purpose: Provide MySQL DBA diagnostics for plugins components installed.
Area: Environment
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Plugins Components Installed') AS script_name;

SELECT 'PLUGIN' AS inventory_type, plugin_name AS name, plugin_status AS status, plugin_type AS type_name, plugin_version AS version
FROM information_schema.plugins
UNION ALL
SELECT 'COMPONENT', component_urn, 'INSTALLED', 'COMPONENT', NULL
FROM mysql.component
ORDER BY inventory_type, name;
