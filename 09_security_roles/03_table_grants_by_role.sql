/*
MySQL DBA Script: Table Grants By Role
Purpose: Provide MySQL DBA diagnostics for table grants by role.
Area: Security Roles
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Table Grants By Role') AS script_name;

SELECT grantee, table_schema, table_name, privilege_type, is_grantable
FROM information_schema.table_privileges
ORDER BY table_schema, table_name, grantee, privilege_type;
