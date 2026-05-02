/*
Oracle DBA Script: Capture Tablespace Usage Snapshot
Purpose: Capture current tablespace metrics into a simple local repository table.
Area: Capacity Forecasting
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Repository DDL plus capture. Review table name/schema before running in production.
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

PROMPT Capture Tablespace Usage Snapshot

CREATE TABLE dba_capacity_tablespace_snap (
    snap_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    tablespace_name VARCHAR2(128) NOT NULL,
    used_bytes NUMBER,
    max_bytes NUMBER,
    used_percent NUMBER,
    CONSTRAINT dba_capacity_tablespace_snap_pk PRIMARY KEY (snap_time, tablespace_name)
);

INSERT INTO dba_capacity_tablespace_snap (tablespace_name, used_bytes, max_bytes, used_percent)
SELECT m.tablespace_name,
       m.used_space * TO_NUMBER(p.value),
       m.tablespace_size * TO_NUMBER(p.value),
       m.used_percent
FROM dba_tablespace_usage_metrics m
CROSS JOIN v$parameter p
WHERE p.name = 'db_block_size';
COMMIT;
