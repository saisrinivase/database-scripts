/*
Oracle DBA Script: High Privilege Roles
Purpose: Provide Oracle DBA diagnostics for high privilege roles.
Area: Security Roles
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

PROMPT High Privilege Roles

SELECT grantee, privilege, admin_option, common, inherited
FROM dba_sys_privs
WHERE privilege IN ('DBA','SYSDBA','SYSOPER','CREATE USER','ALTER USER','DROP USER','GRANT ANY PRIVILEGE','GRANT ANY ROLE','CREATE ANY TABLE','DROP ANY TABLE','ALTER SYSTEM')
ORDER BY grantee, privilege;
