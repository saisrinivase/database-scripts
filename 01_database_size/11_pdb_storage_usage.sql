/*
Oracle DBA Script: PDB Storage Usage
Purpose: Show CDB/PDB storage usage when container metadata is available.
Area: Database Size
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: For CDB environments. In non-CDB databases, use the non-CDB size scripts in this folder.
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

PROMPT PDB Storage Usage

SELECT c.con_id,
       c.name AS container_name,
       ROUND(SUM(df.bytes)/1024/1024/1024, 2) AS datafile_gb,
       ROUND(SUM(CASE WHEN df.autoextensible = 'YES' THEN df.maxbytes ELSE df.bytes END)/1024/1024/1024, 2) AS max_or_fixed_gb
FROM cdb_data_files df
JOIN v$containers c ON c.con_id = df.con_id
GROUP BY c.con_id, c.name
ORDER BY datafile_gb DESC;
