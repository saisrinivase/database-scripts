/*
MySQL DBA Script: Index Maintenance Candidates
Purpose: Provide MySQL DBA diagnostics for index maintenance candidates.
Area: Index Analysis
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Index Maintenance Candidates') AS script_name;

SELECT table_schema, table_name, index_name, non_unique,
       cardinality, nullable, index_type,
       CASE
         WHEN cardinality IS NULL THEN 'ANALYZE_TABLE'
         WHEN index_name <> 'PRIMARY' AND non_unique = 1 THEN 'REVIEW_USAGE_AND_SELECTIVITY'
         ELSE 'MONITOR'
       END AS suggested_action
FROM information_schema.statistics
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY suggested_action, table_schema, table_name, index_name;
