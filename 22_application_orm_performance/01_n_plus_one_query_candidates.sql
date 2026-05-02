/*
MySQL DBA Script: N Plus One Query Candidates
Purpose: Provide MySQL DBA diagnostics for n plus one query candidates.
Area: Application Orm Performance
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: N Plus One Query Candidates') AS script_name;

SELECT schema_name, digest, count_star, sum_errors, sum_warnings, sum_rows_examined,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE count_star >= 100
ORDER BY count_star DESC
LIMIT 100;
