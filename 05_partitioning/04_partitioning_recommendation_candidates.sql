/*
MySQL DBA Script: Partitioning Recommendation Candidates
Purpose: Provide MySQL DBA diagnostics for partitioning recommendation candidates.
Area: Partitioning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Partitioning Recommendation Candidates') AS script_name;

SELECT table_schema, table_name, engine, table_rows,
       ROUND((data_length+index_length)/1024/1024,2) AS total_mb,
       CASE
         WHEN table_rows >= 10000000 OR data_length + index_length >= 10737418240 THEN 'REVIEW_RANGE_OR_HASH_PARTITIONING'
         WHEN update_time < NOW() - INTERVAL 30 DAY THEN 'CHECK_WORKLOAD_BEFORE_PARTITIONING'
         ELSE 'LOW_PRIORITY'
       END AS partitioning_advice
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND table_type = 'BASE TABLE'
ORDER BY total_mb DESC;
