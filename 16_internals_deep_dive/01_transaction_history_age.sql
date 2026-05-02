/*
MySQL DBA Script: Transaction History Age
Purpose: Provide MySQL DBA diagnostics for transaction history age.
Area: Internals Deep Dive
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Transaction History Age') AS script_name;

SELECT trx_id, trx_state, trx_started, TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS trx_age_seconds,
       trx_mysql_thread_id, trx_rows_locked, trx_rows_modified, LEFT(trx_query, 200) AS trx_query
FROM information_schema.innodb_trx
ORDER BY trx_started;
