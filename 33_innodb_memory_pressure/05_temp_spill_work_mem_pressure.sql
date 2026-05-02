/*
MySQL DBA Script: Temp Spill Work Mem Pressure
Purpose: Provide MySQL DBA diagnostics for temp spill work mem pressure.
Area: Innodb Memory Pressure
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Temp Spill Work Mem Pressure') AS script_name;

SELECT event_name, current_alloc, high_alloc
FROM sys.memory_global_by_current_bytes
ORDER BY current_alloc DESC
LIMIT 100;
