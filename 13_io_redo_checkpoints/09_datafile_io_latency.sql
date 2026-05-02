/*
Oracle DBA Script: Datafile IO Latency
Purpose: Estimate datafile read/write latency from V$FILESTAT.
Area: Io Redo Checkpoints
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only cumulative file latency estimate since instance startup.
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

PROMPT Datafile IO Latency

SELECT df.tablespace_name,
       df.file_id,
       df.file_name,
       fs.phyrds,
       fs.phywrts,
       ROUND(fs.readtim / NULLIF(fs.phyrds,0) * 10, 2) AS avg_read_ms,
       ROUND(fs.writetim / NULLIF(fs.phywrts,0) * 10, 2) AS avg_write_ms,
       ROUND(df.bytes/1024/1024/1024, 2) AS file_gb
FROM v$filestat fs
JOIN dba_data_files df ON df.file_id = fs.file#
ORDER BY GREATEST(NVL(fs.readtim / NULLIF(fs.phyrds,0),0), NVL(fs.writetim / NULLIF(fs.phywrts,0),0)) DESC NULLS LAST;
