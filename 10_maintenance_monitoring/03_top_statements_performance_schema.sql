/*
MySQL DBA Script: Top Statements Performance Schema
Purpose: Provide MySQL DBA diagnostics for top statements performance schema.
Area: Maintenance Monitoring
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Top Statements Performance Schema') AS script_name;

SELECT schema_name, digest, count_star,
       ROUND(sum_timer_wait/1000000000000,2) AS total_seconds,
       ROUND(avg_timer_wait/1000000000000,6) AS avg_latency,
       sum_rows_examined, sum_rows_sent, sum_errors, sum_warnings,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE digest IS NOT NULL
ORDER BY sum_timer_wait DESC
LIMIT 100;
