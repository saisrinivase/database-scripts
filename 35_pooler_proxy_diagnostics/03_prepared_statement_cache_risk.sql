/*
MySQL DBA Script: Prepared Statement Cache Risk
Purpose: Provide MySQL DBA diagnostics for prepared statement cache risk.
Area: Pooler Proxy Diagnostics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Prepared Statement Cache Risk') AS script_name;

SELECT owner_thread_id, statement_id, statement_name, sql_text, count_reprepare, count_execute
FROM performance_schema.prepared_statements_instances
ORDER BY count_execute DESC;
