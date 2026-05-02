/*
Oracle DBA Script: Create Capacity Repository
Purpose: Provide Oracle DBA diagnostics for create capacity repository.
Area: Capacity Forecasting
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

PROMPT Create Capacity Repository

CREATE TABLE dba_capacity_database_snap (
    snap_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    database_name VARCHAR2(128),
    allocated_bytes NUMBER,
    segment_bytes NUMBER,
    tempfile_bytes NUMBER,
    redo_bytes NUMBER
);

CREATE TABLE dba_capacity_segment_snap (
    snap_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    owner VARCHAR2(128),
    segment_name VARCHAR2(128),
    segment_type VARCHAR2(30),
    tablespace_name VARCHAR2(128),
    bytes NUMBER
);
