/*
MySQL DBA Script: Select Star Candidates
Purpose: Provide MySQL DBA diagnostics for select star candidates.
Area: Application Orm Performance
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Select Star Candidates') AS script_name;

SELECT schema_name, digest, count_star, sum_rows_examined, LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE digest_text LIKE 'SELECT *%'
ORDER BY sum_rows_examined DESC
LIMIT 100;
