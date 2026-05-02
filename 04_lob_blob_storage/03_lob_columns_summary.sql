/*
MySQL DBA Script: Lob Columns Summary
Purpose: Provide MySQL DBA diagnostics for lob columns summary.
Area: Lob Blob Storage
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Lob Columns Summary') AS script_name;

SELECT table_schema, COUNT(*) AS lob_columns,
       SUM(data_type IN ('blob','tinyblob','mediumblob','longblob')) AS blob_columns,
       SUM(data_type IN ('text','tinytext','mediumtext','longtext')) AS text_columns,
       SUM(data_type = 'json') AS json_columns
FROM information_schema.columns
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND data_type IN ('blob','tinyblob','mediumblob','longblob','text','tinytext','mediumtext','longtext','json')
GROUP BY table_schema
ORDER BY lob_columns DESC;
