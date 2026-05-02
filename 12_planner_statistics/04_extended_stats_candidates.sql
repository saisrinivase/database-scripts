/*
MySQL DBA Script: Extended Stats Candidates
Purpose: Provide MySQL DBA diagnostics for extended stats candidates.
Area: Planner Statistics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Extended Stats Candidates') AS script_name;

SELECT schema_name, table_name, column_name, histogram->>'$."number-of-buckets-specified"' AS buckets,
       histogram->>'$."last-updated"' AS last_updated
FROM information_schema.column_statistics
WHERE schema_name NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY schema_name, table_name, column_name;
