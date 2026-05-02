/*
Oracle DBA Script: Create Lifecycle Repository
Purpose: Provide Oracle DBA diagnostics for create lifecycle repository.
Area: Object Lifecycle Capacity
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

PROMPT Create Lifecycle Repository

CREATE TABLE dba_lifecycle_object_snap (
    snap_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    owner VARCHAR2(128),
    object_name VARCHAR2(128),
    object_type VARCHAR2(30),
    status VARCHAR2(30),
    bytes NUMBER,
    last_ddl_time DATE
);

CREATE TABLE dba_lifecycle_ddl_audit (
    event_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    ora_sysevent VARCHAR2(64),
    ora_dict_obj_owner VARCHAR2(128),
    ora_dict_obj_name VARCHAR2(128),
    ora_dict_obj_type VARCHAR2(64),
    login_user VARCHAR2(128)
);
