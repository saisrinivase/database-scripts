/*
Oracle DBA Script: Cloud Incident Window Checklist
Purpose: Provide Oracle DBA diagnostics for cloud incident window checklist.
Area: Cloud Provider Signals
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

PROMPT Cloud Incident Window Checklist

SELECT 'Capture AWR/ASH window, alert log messages, archivelog gaps, tablespace usage, and top wait events' AS incident_evidence_item FROM dual
UNION ALL SELECT 'Check cloud console events, storage burst balance, IOPS throttling, and maintenance windows' FROM dual
UNION ALL SELECT 'Record database role, open mode, Data Guard lag, recent backups, and changed parameters' FROM dual;
