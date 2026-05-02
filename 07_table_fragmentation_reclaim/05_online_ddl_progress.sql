/*
MySQL DBA Script: Online Ddl Progress
Purpose: Provide MySQL DBA diagnostics for online ddl progress.
Area: Table Fragmentation Reclaim
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Online Ddl Progress') AS script_name;

SELECT event_name, work_completed, work_estimated,
       ROUND(work_completed / NULLIF(work_estimated,0) * 100, 2) AS pct_complete
FROM performance_schema.events_stages_current
WHERE event_name LIKE 'stage/innodb/alter table%'
   OR event_name LIKE 'stage/sql/%alter%';
