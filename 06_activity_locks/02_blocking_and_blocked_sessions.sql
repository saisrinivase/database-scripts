/*
MySQL DBA Script: Blocking And Blocked Sessions
Purpose: Provide MySQL DBA diagnostics for blocking and blocked sessions.
Area: Activity Locks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Blocking And Blocked Sessions') AS script_name;

SELECT r.trx_mysql_thread_id AS waiting_thread,
       r.trx_query AS waiting_query,
       b.trx_mysql_thread_id AS blocking_thread,
       b.trx_query AS blocking_query,
       TIMESTAMPDIFF(SECOND, r.trx_started, NOW()) AS waiting_seconds
FROM information_schema.innodb_lock_waits w
JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id
JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
ORDER BY waiting_seconds DESC;
