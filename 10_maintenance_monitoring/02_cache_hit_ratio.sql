/*
MySQL DBA Script: Cache Hit Ratio
Purpose: Provide MySQL DBA diagnostics for cache hit ratio.
Area: Maintenance Monitoring
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Cache Hit Ratio') AS script_name;

SELECT ROUND((1 - (reads.variable_value / NULLIF(requests.variable_value,0))) * 100, 2) AS buffer_pool_hit_pct,
       requests.variable_value AS logical_read_requests,
       reads.variable_value AS physical_reads
FROM performance_schema.global_status requests
JOIN performance_schema.global_status reads
WHERE requests.variable_name = 'Innodb_buffer_pool_read_requests'
  AND reads.variable_name = 'Innodb_buffer_pool_reads';
