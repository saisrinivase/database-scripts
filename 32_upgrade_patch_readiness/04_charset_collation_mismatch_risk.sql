/*
MySQL DBA Script: Charset Collation Mismatch Risk
Purpose: Provide MySQL DBA diagnostics for charset collation mismatch risk.
Area: Upgrade Patch Readiness
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Charset Collation Mismatch Risk') AS script_name;

SELECT table_schema, table_name, table_collation, COUNT(*) AS columns
FROM information_schema.columns c
JOIN information_schema.tables t ON t.table_schema=c.table_schema AND t.table_name=c.table_name
WHERE c.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_name, table_collation
ORDER BY table_schema, table_name;
