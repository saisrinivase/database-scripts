/*
MySQL DBA Script: Tablespaces Size
Purpose: Provide MySQL DBA diagnostics for tablespaces size.
Area: Database Size
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Tablespaces Size') AS script_name;

SELECT name AS tablespace_name,
       space_type,
       row_format,
       page_size,
       ROUND(file_size/1024/1024,2) AS file_mb,
       ROUND(allocated_size/1024/1024,2) AS allocated_mb,
       state
FROM information_schema.innodb_tablespaces
ORDER BY file_size DESC;
