/*
MySQL DBA Script: Plan Red Flag Candidates
Purpose: Provide MySQL DBA diagnostics for plan red flag candidates.
Area: Execution Plans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Plan Red Flag Candidates') AS script_name;

SELECT schema_name, digest, sum_no_index_used, sum_no_good_index_used, sum_rows_examined, count_star,
       LEFT(digest_text, 200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE sum_no_index_used > 0 OR sum_no_good_index_used > 0 OR sum_rows_examined > 1000000
ORDER BY sum_rows_examined DESC
LIMIT 100;
