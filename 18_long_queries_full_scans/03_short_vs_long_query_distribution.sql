/*
MySQL DBA Script: Short Vs Long Query Distribution
Purpose: Provide MySQL DBA diagnostics for short vs long query distribution.
Area: Long Queries Full Scans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Short Vs Long Query Distribution') AS script_name;

SELECT CASE
         WHEN avg_timer_wait/1000000000000 < 1 THEN '<1s'
         WHEN avg_timer_wait/1000000000000 < 10 THEN '1-10s'
         WHEN avg_timer_wait/1000000000000 < 60 THEN '10-60s'
         ELSE '>=60s'
       END AS avg_latency_bucket,
       COUNT(*) AS digest_count
FROM performance_schema.events_statements_summary_by_digest
GROUP BY avg_latency_bucket
ORDER BY digest_count DESC;
