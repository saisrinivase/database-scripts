/*
MySQL DBA Script: Fix Performance Lab Issues
Purpose: Provide MySQL DBA diagnostics for fix performance lab issues.
Area: Mysql Health Validation
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Fix Performance Lab Issues') AS script_name;

CREATE TABLE IF NOT EXISTS mysql_perf_lab_fullscan (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  group_id INT NOT NULL,
  payload VARCHAR(200)
);
INSERT INTO mysql_perf_lab_fullscan(group_id, payload)
SELECT seq % 100, REPEAT('x',200)
FROM sys.seq_1_to_10000;
