/*
Oracle DBA Script: Roles And Membership
Purpose: Provide Oracle DBA diagnostics for roles and membership.
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

PROMPT Roles And Membership

SELECT u.username, u.account_status, u.lock_date, u.expiry_date, u.default_tablespace,
       u.temporary_tablespace, u.profile, r.granted_role, r.admin_option, r.default_role
FROM dba_users u
LEFT JOIN dba_role_privs r ON r.grantee = u.username
ORDER BY u.username, r.granted_role;
