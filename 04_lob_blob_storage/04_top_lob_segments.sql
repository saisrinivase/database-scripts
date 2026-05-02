/*
Oracle DBA Script: Top Lob Segments
Purpose: Provide Oracle DBA diagnostics for top lob segments.
Area: Lob Blob Storage
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

PROMPT Top Lob Segments

SELECT * FROM (
    SELECT l.owner, l.table_name, l.column_name, l.segment_name, l.tablespace_name,
           l.securefile, l.compression, l.deduplication, l.in_row,
           ROUND(NVL(s.bytes,0)/1024/1024,2) AS lob_segment_mb
    FROM dba_lobs l
    LEFT JOIN dba_segments s ON s.owner = l.owner AND s.segment_name = l.segment_name
    WHERE l.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    ORDER BY NVL(s.bytes,0) DESC
) WHERE ROWNUM <= 50;
