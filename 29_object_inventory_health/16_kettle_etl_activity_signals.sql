/*
MySQL DBA Script: Kettle Etl Activity Signals
Purpose: Provide MySQL DBA diagnostics for kettle etl activity signals.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Kettle Etl Activity Signals') AS script_name;

SELECT schema_name, digest, count_star, LEFT(digest_text,200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
WHERE UPPER(digest_text) LIKE '%KETTLE%' OR UPPER(digest_text) LIKE '%PENTAHO%'
ORDER BY count_star DESC;
