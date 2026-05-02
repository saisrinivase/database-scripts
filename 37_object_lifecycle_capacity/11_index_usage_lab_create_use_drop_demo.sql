/*
MySQL DBA Script: Index Usage Lab Create Use Drop Demo
Purpose: Provide MySQL DBA diagnostics for index usage lab create use drop demo.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Index Usage Lab Create Use Drop Demo') AS script_name;

CREATE TABLE IF NOT EXISTS dba_lifecycle_lab_table (id BIGINT PRIMARY KEY AUTO_INCREMENT, payload VARCHAR(100));
CREATE INDEX dba_lifecycle_lab_idx ON dba_lifecycle_lab_table(payload);
INSERT INTO dba_lifecycle_lab_table(payload) VALUES ('lifecycle demo');
