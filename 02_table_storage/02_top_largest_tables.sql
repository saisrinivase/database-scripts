/*
Oracle DBA Script: Top Largest Tables
Purpose: Provide Oracle DBA diagnostics for top largest tables.
Area: Table Storage
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

PROMPT Top Largest Tables

SELECT * FROM (
    SELECT s.owner, s.segment_name AS table_name, s.tablespace_name,
           ROUND(SUM(s.bytes)/1024/1024,2) AS segment_mb,
           MAX(t.num_rows) AS num_rows,
           MAX(t.last_analyzed) AS last_analyzed
    FROM dba_segments s
    LEFT JOIN dba_tables t ON t.owner = s.owner AND t.table_name = s.segment_name
    WHERE s.segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
      AND s.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    GROUP BY s.owner, s.segment_name, s.tablespace_name
    ORDER BY SUM(s.bytes) DESC
) WHERE ROWNUM <= 50;
