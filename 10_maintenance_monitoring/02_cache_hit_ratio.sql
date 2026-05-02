/*
Oracle DBA Script: Cache Hit Ratio
Purpose: Provide Oracle DBA diagnostics for cache hit ratio.
Area: Maintenance Monitoring
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

PROMPT Cache Hit Ratio

WITH s AS (
    SELECT name, value FROM v$sysstat
    WHERE name IN ('db block gets','consistent gets','physical reads','session logical reads')
)
SELECT ROUND((1 - (pr.value / NULLIF((dbg.value + cg.value),0))) * 100, 2) AS buffer_cache_hit_pct,
       dbg.value AS db_block_gets,
       cg.value AS consistent_gets,
       pr.value AS physical_reads
FROM s dbg
CROSS JOIN s cg
CROSS JOIN s pr
WHERE dbg.name = 'db block gets'
  AND cg.name = 'consistent gets'
  AND pr.name = 'physical reads';
