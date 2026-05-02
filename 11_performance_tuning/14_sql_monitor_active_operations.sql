/*
Oracle DBA Script: SQL Monitor Active Operations
Purpose: List active or recently monitored SQL operations.
Area: Performance Tuning
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only SQL Monitor list; SQL Monitor/AWR usage may require Diagnostics/Tuning Pack licensing.
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

PROMPT SQL Monitor Active Operations

SELECT * FROM (
    SELECT inst_id,
           status,
           sql_id,
           sql_exec_id,
           sql_exec_start,
           username,
           module,
           program,
           ROUND(elapsed_time/1000000, 2) AS elapsed_seconds,
           ROUND(cpu_time/1000000, 2) AS cpu_seconds,
           buffer_gets,
           ROUND(physical_read_bytes/1024/1024, 2) AS physical_read_mb,
           ROUND(physical_write_bytes/1024/1024, 2) AS physical_write_mb
    FROM gv$sql_monitor
    ORDER BY sql_exec_start DESC NULLS LAST, elapsed_time DESC
) WHERE ROWNUM <= 100;
