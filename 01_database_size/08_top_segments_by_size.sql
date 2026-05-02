/*
Oracle DBA Script: Top Segments By Size
Purpose: Rank current largest segments across application schemas.
Area: Database Size
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only current segment inventory.
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

PROMPT Top Segments By Size

SELECT * FROM (
    SELECT owner,
           segment_name,
           partition_name,
           segment_type,
           tablespace_name,
           ROUND(bytes/1024/1024/1024, 2) AS segment_gb,
           extents,
           blocks
    FROM dba_segments
    WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    ORDER BY bytes DESC
) WHERE ROWNUM <= 100;
