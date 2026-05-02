/*
Oracle DBA Script: Version Upgrade Path Overview
Purpose: Provide Oracle DBA diagnostics for version upgrade path overview.
Area: Upgrade Patch Readiness
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

PROMPT Version Upgrade Path Overview

SELECT i.version, i.version_full, d.compatibility, d.name, d.platform_name
FROM v$instance i CROSS JOIN v$database d;
