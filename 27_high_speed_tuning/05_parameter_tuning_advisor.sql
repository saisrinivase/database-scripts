/*
Oracle DBA Script: Parameter Tuning Advisor
Purpose: Provide Oracle DBA diagnostics for parameter tuning advisor.
Area: High Speed Tuning
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

PROMPT Parameter Tuning Advisor

SELECT name AS parameter_name, value, isdefault, ismodified, issys_modifiable, description
FROM v$parameter
WHERE name IN ('sga_target','sga_max_size','pga_aggregate_target','memory_target','db_cache_size','shared_pool_size','filesystemio_options','db_file_multiblock_read_count')
ORDER BY name;
