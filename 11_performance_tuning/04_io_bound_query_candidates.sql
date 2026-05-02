/*
MySQL DBA Script: Io Bound Query Candidates
Purpose: Provide MySQL DBA diagnostics for io bound query candidates.
Area: Performance Tuning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Io Bound Query Candidates') AS script_name;

SELECT schema_name, digest, count_star, sum_rows_examined, sum_rows_sent,
       sum_no_index_used, sum_no_good_index_used,
       ROUND(sum_timer_wait/1000000000000,2) AS total_seconds,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_rows_examined DESC
LIMIT 100;
