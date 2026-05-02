/*
MySQL DBA Script: High Privilege Roles
Purpose: Provide MySQL DBA diagnostics for high privilege roles.
Area: Security Roles
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: High Privilege Roles') AS script_name;

SELECT user, host, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv,
       Reload_priv, Shutdown_priv, Process_priv, File_priv, Grant_priv, Super_priv, Create_user_priv
FROM mysql.user
WHERE Super_priv='Y' OR Grant_priv='Y' OR Create_user_priv='Y' OR File_priv='Y' OR Process_priv='Y'
ORDER BY user, host;
