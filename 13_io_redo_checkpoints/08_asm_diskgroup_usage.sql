/*
Oracle DBA Script: ASM Diskgroup Usage
Purpose: Show ASM diskgroup capacity and free percentage when ASM views are accessible.
Area: Io Redo Checkpoints
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Requires access to ASM dynamic performance views; skip on non-ASM deployments.
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

PROMPT ASM Diskgroup Usage

SELECT name AS diskgroup_name,
       state,
       type,
       ROUND(total_mb/1024, 2) AS total_gb,
       ROUND(free_mb/1024, 2) AS free_gb,
       ROUND(usable_file_mb/1024, 2) AS usable_file_gb,
       ROUND((total_mb-free_mb)/NULLIF(total_mb,0)*100, 2) AS used_pct
FROM v$asm_diskgroup
ORDER BY used_pct DESC;
