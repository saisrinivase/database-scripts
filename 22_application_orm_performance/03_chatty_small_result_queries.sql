/*
MySQL DBA Script: Chatty Small Result Queries
Purpose: Provide MySQL DBA diagnostics for chatty small result queries.
Area: Application Orm Performance
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Chatty Small Result Queries') AS script_name;

SELECT schema_name, digest, count_star,
       ROUND(avg_timer_wait/1000000000000,6) AS avg_seconds,
       sum_rows_sent/NULLIF(count_star,0) AS avg_rows_sent,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE count_star >= 1000
ORDER BY count_star DESC
LIMIT 100;
