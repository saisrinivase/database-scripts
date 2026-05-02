/*
Oracle DBA Script: Error Signature Indicators
Purpose: Provide Oracle DBA diagnostics for error signature indicators.
Area: Logging Error Signatures
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

PROMPT Error Signature Indicators

SELECT originating_timestamp, message_type, message_level, problem_key, message_text
FROM v$diag_alert_ext
WHERE originating_timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
  AND REGEXP_LIKE(message_text, 'ORA-|error|deadlock|corrupt|timeout', 'i')
ORDER BY originating_timestamp DESC;
