/*
Oracle DBA Script: Tablespaces Size
Purpose: Provide Oracle DBA diagnostics for tablespaces size.
Area: Database Size
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

PROMPT Tablespaces Size

WITH datafiles AS (
    SELECT tablespace_name, SUM(bytes) bytes, SUM(maxbytes) maxbytes
    FROM dba_data_files GROUP BY tablespace_name
), free_space AS (
    SELECT tablespace_name, SUM(bytes) free_bytes
    FROM dba_free_space GROUP BY tablespace_name
)
SELECT
    t.tablespace_name,
    t.contents,
    t.status,
    ROUND(df.bytes / 1024 / 1024, 2) AS allocated_mb,
    ROUND(NVL(fs.free_bytes, 0) / 1024 / 1024, 2) AS free_mb,
    ROUND((df.bytes - NVL(fs.free_bytes, 0)) / NULLIF(df.bytes, 0) * 100, 2) AS used_pct,
    ROUND(df.maxbytes / 1024 / 1024, 2) AS max_mb
FROM dba_tablespaces t
LEFT JOIN datafiles df ON df.tablespace_name = t.tablespace_name
LEFT JOIN free_space fs ON fs.tablespace_name = t.tablespace_name
ORDER BY used_pct DESC NULLS LAST, allocated_mb DESC;
