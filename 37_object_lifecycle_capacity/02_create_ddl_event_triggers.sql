/*
Oracle DBA Script: Create Ddl Event Triggers
Purpose: Provide Oracle DBA diagnostics for create ddl event triggers.
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

PROMPT Create Ddl Event Triggers

CREATE OR REPLACE TRIGGER dba_lifecycle_ddl_audit_trg
AFTER DDL ON DATABASE
BEGIN
  INSERT INTO dba_lifecycle_ddl_audit (
      ora_sysevent, ora_dict_obj_owner, ora_dict_obj_name, ora_dict_obj_type, login_user
  ) VALUES (
      ORA_SYSEVENT, ORA_DICT_OBJ_OWNER, ORA_DICT_OBJ_NAME, ORA_DICT_OBJ_TYPE, ORA_LOGIN_USER
  );
END;
/
