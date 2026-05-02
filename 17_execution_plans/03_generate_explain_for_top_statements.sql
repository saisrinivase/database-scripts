/*
MySQL DBA Script: Generate Explain For Top Statements
Purpose: Provide MySQL DBA diagnostics for generate explain for top statements.
Area: Execution Plans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Generate Explain For Top Statements') AS script_name;

SELECT CONCAT('EXPLAIN FORMAT=TREE ', LEFT(digest_text, 500), ';') AS explain_command
FROM performance_schema.events_statements_summary_by_digest
WHERE digest_text IS NOT NULL AND digest_text LIKE 'SELECT%'
ORDER BY sum_timer_wait DESC
LIMIT 20;
