/*
Oracle DBA Script: Server Instance Overview
Purpose: Provide Oracle DBA diagnostics for server instance overview.
Area: Environment
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

PROMPT Server Instance Overview

SELECT
    d.name AS database_name,
    d.dbid,
    d.database_role,
    d.open_mode,
    d.log_mode,
    d.force_logging,
    d.flashback_on,
    i.instance_name,
    i.host_name,
    i.version,
    i.status AS instance_status,
    i.database_status,
    i.startup_time,
    ROUND(SYSDATE - i.startup_time, 2) AS uptime_days,
    d.platform_name
FROM v$database d
CROSS JOIN v$instance i;
