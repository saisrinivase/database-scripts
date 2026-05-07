/*
PostgreSQL DBA Script: Config File Unknown Or Deprecated Gucs
Purpose: Identify configuration-file errors and unapplied parameters that can appear after upgrade/patch changes.
Area: Upgrade and Patch Readiness
Usage: Resolve rows with non-null error before restart/cutover.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    sourcefile,
    sourceline,
    seqno,
    name,
    setting,
    applied,
    error,
    CASE
        WHEN error IS NOT NULL THEN 'CONFIG_ERROR'
        WHEN applied = false THEN 'NOT_APPLIED'
        ELSE 'OK'
    END AS status,
    CASE
        WHEN error IS NOT NULL THEN 'Fix unknown/invalid parameter and reload/restart as required.'
        WHEN applied = false THEN 'Parameter exists but is currently not applied; validate context and restart policy.'
        ELSE 'No action.'
    END AS action_hint
FROM pg_file_settings
WHERE error IS NOT NULL
   OR applied = false
ORDER BY sourcefile, sourceline, seqno;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  sourcefile | sourceline | seqno | name | setting | applied | error | status | action_hint 
-- ------------+------------+-------+------+---------+---------+-------+--------+-------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
