/*
MySQL DBA Script: Resource Percent By Schema
Purpose: Provide MySQL DBA diagnostics for resource percent by schema.
Area: Sql Resource Attribution
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Resource Percent By Schema') AS script_name;

SELECT schema_name, COUNT(*) AS digest_count,
       ROUND(SUM(sum_timer_wait)/1000000000000,2) AS total_seconds,
       ROUND(SUM(sum_timer_wait) / NULLIF((SELECT SUM(sum_timer_wait) FROM performance_schema.events_statements_summary_by_digest),0) * 100,2) AS pct
FROM performance_schema.events_statements_summary_by_digest
GROUP BY schema_name
ORDER BY total_seconds DESC;
