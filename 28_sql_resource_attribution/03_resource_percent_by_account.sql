/*
MySQL DBA Script: Resource Percent By Account
Purpose: Provide MySQL DBA diagnostics for resource percent by account.
Area: Sql Resource Attribution
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Resource Percent By Account') AS script_name;

SELECT user, host, count_star, sum_timer_wait/1000000000000 AS total_seconds,
       current_connections, total_connections
FROM performance_schema.accounts
ORDER BY sum_timer_wait DESC;
