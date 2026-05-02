/*
MySQL DBA Script: Mvcc Purge Profile
Purpose: Provide MySQL DBA diagnostics for mvcc purge profile.
Area: Internals Deep Dive
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Mvcc Purge Profile') AS script_name;

SELECT name, count, max_count, comment
FROM information_schema.innodb_metrics
WHERE name LIKE 'trx%' OR name LIKE 'purge%'
ORDER BY name;
