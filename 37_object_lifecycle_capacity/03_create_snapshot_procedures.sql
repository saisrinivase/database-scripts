/*
Oracle DBA Script: Create Snapshot Procedures
Purpose: Provide Oracle DBA diagnostics for create snapshot procedures.
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

PROMPT Create Snapshot Procedures

CREATE OR REPLACE PROCEDURE capture_dba_lifecycle_snapshot AS
BEGIN
  INSERT INTO dba_lifecycle_object_snap (owner, object_name, object_type, status, bytes, last_ddl_time)
  SELECT o.owner, o.object_name, o.object_type, o.status, s.bytes, o.last_ddl_time
  FROM dba_objects o
  LEFT JOIN dba_segments s ON s.owner = o.owner AND s.segment_name = o.object_name
  WHERE o.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS');
  COMMIT;
END;
/
