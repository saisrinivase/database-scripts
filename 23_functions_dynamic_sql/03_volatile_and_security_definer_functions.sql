/*
Oracle DBA Script: Volatile And Security Definer Functions
Purpose: Provide Oracle DBA diagnostics for volatile and security definer functions.
Area: Functions Dynamic Sql
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

PROMPT Volatile And Security Definer Functions

SELECT owner, object_name, procedure_name, object_type, authid, deterministic, pipelined, aggregate
FROM dba_procedures
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND (authid = 'DEFINER' OR deterministic = 'NO')
ORDER BY owner, object_name, procedure_name;
