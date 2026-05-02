/*
MySQL DBA Script: Object Statement Hotspots
Purpose: Provide MySQL DBA diagnostics for object statement hotspots.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Object Statement Hotspots') AS script_name;

SELECT schema_name, digest, count_star,
       ROUND(sum_timer_wait/1000000000000,2) AS total_seconds,
       ROUND(sum_timer_wait / NULLIF((SELECT SUM(sum_timer_wait) FROM performance_schema.events_statements_summary_by_digest),0) * 100,2) AS total_pct,
       sum_rows_examined, sum_rows_sent, LEFT(digest_text,200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 100;
