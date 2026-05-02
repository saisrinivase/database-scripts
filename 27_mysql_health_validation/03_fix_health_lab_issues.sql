/*
MySQL DBA Script: Fix Health Lab Issues
Purpose: Provide MySQL DBA diagnostics for fix health lab issues.
Area: Mysql Health Validation
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Fix Health Lab Issues') AS script_name;

ALTER TABLE mysql_health_lab_no_pk ADD PRIMARY KEY (id);
ANALYZE TABLE mysql_health_lab_stale_stats;
