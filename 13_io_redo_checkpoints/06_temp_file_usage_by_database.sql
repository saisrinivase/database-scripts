/*
MySQL DBA Script: Temp File Usage By Database
Purpose: Provide MySQL DBA diagnostics for temp file usage by database.
Area: Io Redo Checkpoints
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Temp File Usage By Database') AS script_name;

SELECT schema_name, digest, count_star, sum_created_tmp_tables, sum_created_tmp_disk_tables,
       ROUND(sum_timer_wait/1000000000000,2) AS total_seconds,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE sum_created_tmp_tables > 0 OR sum_created_tmp_disk_tables > 0
ORDER BY sum_created_tmp_disk_tables DESC, sum_created_tmp_tables DESC
LIMIT 100;
