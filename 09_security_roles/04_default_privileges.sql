/*
MySQL DBA Script: Default Privileges
Purpose: Provide MySQL DBA diagnostics for default privileges.
Area: Security Roles
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Default Privileges') AS script_name;

SELECT user, host, default_role_user, default_role_host
FROM mysql.default_roles
ORDER BY user, host;
