/*
MySQL DBA Script: Database Io Profile
Purpose: Provide MySQL DBA diagnostics for database io profile.
Area: Io Redo Checkpoints
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Database Io Profile') AS script_name;

SELECT file_name, event_name, count_read, count_write,
       sum_number_of_bytes_read, sum_number_of_bytes_write
FROM performance_schema.file_summary_by_instance
ORDER BY (sum_number_of_bytes_read + sum_number_of_bytes_write) DESC
LIMIT 100;
