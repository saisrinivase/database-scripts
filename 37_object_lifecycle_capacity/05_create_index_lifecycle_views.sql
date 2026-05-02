/*
Oracle DBA Script: Create Index Lifecycle Views
Purpose: Provide Oracle DBA diagnostics for create index lifecycle views.
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

PROMPT Create Index Lifecycle Views

CREATE OR REPLACE VIEW dba_index_lifecycle_v AS
SELECT i.owner, i.index_name, i.table_owner, i.table_name, i.status, i.visibility,
       i.last_analyzed, s.bytes
FROM dba_indexes i
LEFT JOIN dba_segments s ON s.owner = i.owner AND s.segment_name = i.index_name;
