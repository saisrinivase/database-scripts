/*
Oracle DBA Script: Index Usage Lab Create Use Drop Demo
Purpose: Provide Oracle DBA diagnostics for index usage lab create use drop demo.
Area: Object Lifecycle Capacity
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Review findings before taking action. Some performance history views require the Oracle Diagnostics Pack license.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN segment_name FORMAT A38
COLUMN table_name FORMAT A38
COLUMN index_name FORMAT A38
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Index Usage Lab Create Use Drop Demo

CREATE TABLE dba_lifecycle_lab_table (id NUMBER PRIMARY KEY, payload VARCHAR2(100));
CREATE INDEX dba_lifecycle_lab_idx ON dba_lifecycle_lab_table(payload);
INSERT INTO dba_lifecycle_lab_table VALUES (1, 'lifecycle demo');
COMMIT;
