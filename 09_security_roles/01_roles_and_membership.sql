/*
MySQL DBA Script: Roles And Membership
Purpose: Provide MySQL DBA diagnostics for roles and membership.
Area: Security Roles
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Roles And Membership') AS script_name;

SELECT user, host, account_locked, password_expired, password_last_changed, password_lifetime,
       plugin, authentication_string IS NOT NULL AS has_auth_string
FROM mysql.user
ORDER BY user, host;
