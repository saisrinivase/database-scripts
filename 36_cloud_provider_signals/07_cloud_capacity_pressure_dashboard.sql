/*
Oracle DBA Script: Cloud Capacity Pressure Dashboard
Purpose: Combine tablespace, TEMP, FRA, and archive pressure signals for cloud incidents.
Area: Cloud Provider Signals
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only cross-area capacity pressure dashboard.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN tablespace_name FORMAT A30
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN metric_name FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Cloud Capacity Pressure Dashboard

SELECT 'TABLESPACE_OVER_85_PCT' AS signal_name, COUNT(*) AS finding_count
FROM dba_tablespace_usage_metrics
WHERE used_percent >= 85
UNION ALL
SELECT 'TEMP_OVER_85_PCT', COUNT(*)
FROM (
    SELECT tablespace_name, SUM(bytes_used)/NULLIF(SUM(bytes_used+bytes_free),0)*100 AS used_pct
    FROM v$temp_space_header
    GROUP BY tablespace_name
) WHERE used_pct >= 85
UNION ALL
SELECT 'FRA_OVER_85_PCT', COUNT(*)
FROM v$recovery_file_dest
WHERE space_used/NULLIF(space_limit,0)*100 >= 85
UNION ALL
SELECT 'ARCHIVE_DEST_ERRORS', COUNT(*)
FROM v$archive_dest_status
WHERE error IS NOT NULL;
