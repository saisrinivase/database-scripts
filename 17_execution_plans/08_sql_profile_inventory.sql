/*
Oracle DBA Script: SQL Profile Inventory
Purpose: Inventory SQL profiles and categories.
Area: Execution Plans
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Requires access to DBA_SQL_PROFILES.
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

PROMPT SQL Profile Inventory

SELECT name,
       category,
       status,
       type,
       force_matching,
       created,
       last_modified,
       description
FROM dba_sql_profiles
ORDER BY last_modified DESC NULLS LAST, created DESC;
