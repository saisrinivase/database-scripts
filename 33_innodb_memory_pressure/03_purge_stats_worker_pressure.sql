/*
MySQL DBA Script: Purge Stats Worker Pressure
Purpose: Provide MySQL DBA diagnostics for purge stats worker pressure.
Area: Innodb Memory Pressure
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Purge Stats Worker Pressure') AS script_name;

SELECT name, count, max_count, comment
FROM information_schema.innodb_metrics
WHERE name LIKE 'purge%' OR name LIKE 'trx_rseg_history_len'
ORDER BY name;
