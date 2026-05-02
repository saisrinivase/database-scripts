/*
Oracle DBA Script: Performance Sanity Checks
Purpose: Provide Oracle DBA diagnostics for performance sanity checks.
Area: Oracle Health Validation
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

PROMPT Performance Sanity Checks

SELECT 'INVALID_OBJECTS' AS check_name, COUNT(*) AS finding_count FROM dba_objects WHERE status <> 'VALID'
UNION ALL SELECT 'DISABLED_CONSTRAINTS', COUNT(*) FROM dba_constraints WHERE status <> 'ENABLED'
UNION ALL SELECT 'STALE_TABLE_STATS', COUNT(*) FROM dba_tab_statistics WHERE object_type = 'TABLE' AND stale_stats = 'YES'
UNION ALL SELECT 'TABLESPACES_OVER_85_PCT', COUNT(*) FROM (
    SELECT df.tablespace_name
    FROM (SELECT tablespace_name, SUM(bytes) bytes FROM dba_data_files GROUP BY tablespace_name) df
    LEFT JOIN (SELECT tablespace_name, SUM(bytes) free_bytes FROM dba_free_space GROUP BY tablespace_name) fs ON fs.tablespace_name = df.tablespace_name
    WHERE (df.bytes - NVL(fs.free_bytes,0)) / df.bytes > 0.85
);
