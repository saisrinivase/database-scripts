/*
PostgreSQL DBA Script: Extension Version Drift Dependencies
Purpose: Detect extension version drift and quantify extension-owned dependency footprint.
Area: Upgrade and Patch Readiness
Usage: Run before upgrade to avoid extension-related downtime surprises.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH ext AS (
    SELECT
        e.oid,
        e.extname,
        e.extversion,
        n.nspname AS extension_schema
    FROM pg_extension e
    JOIN pg_namespace n
      ON n.oid = e.extnamespace
),
avail AS (
    SELECT
        a.name AS extname,
        a.default_version,
        a.comment
    FROM pg_available_extensions a
),
obj AS (
    SELECT
        d.refobjid AS ext_oid,
        count(*) FILTER (WHERE d.deptype = 'e') AS extension_owned_objects
    FROM pg_depend d
    GROUP BY d.refobjid
)
SELECT
    ext.extname,
    ext.extension_schema,
    ext.extversion AS installed_version,
    avail.default_version,
    coalesce(obj.extension_owned_objects, 0) AS extension_owned_objects,
    CASE
        WHEN avail.default_version IS NULL THEN 'UNKNOWN_IN_AVAILABLE_EXTENSIONS'
        WHEN ext.extversion = avail.default_version THEN 'UP_TO_DATE_OR_DEFAULT'
        ELSE 'VERSION_DRIFT_REVIEW'
    END AS upgrade_readiness,
    coalesce(avail.comment, '(no comment)') AS extension_comment,
    CASE
        WHEN coalesce(obj.extension_owned_objects, 0) > 1000 THEN 'High dependency footprint: test extension upgrade in staging first.'
        WHEN coalesce(obj.extension_owned_objects, 0) > 0 THEN 'Review extension release notes and regression test dependent objects.'
        ELSE 'Low direct dependency footprint.'
    END AS action_hint
FROM ext
LEFT JOIN avail
  ON avail.extname = ext.extname
LEFT JOIN obj
  ON obj.ext_oid = ext.oid
ORDER BY
    CASE
        WHEN avail.default_version IS NULL THEN 1
        WHEN ext.extversion <> avail.default_version THEN 2
        ELSE 3
    END,
    ext.extname;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--       extname       | extension_schema | installed_version | default_version | extension_owned_objects |   upgrade_readiness   |                           extension_comment                            |                              action_hint                              
-- --------------------+------------------+-------------------+-----------------+-------------------------+-----------------------+------------------------------------------------------------------------+-----------------------------------------------------------------------
--  pg_stat_statements | public           | 1.12              | 1.12            |                       9 | UP_TO_DATE_OR_DEFAULT | track planning and execution statistics of all SQL statements executed | Review extension release notes and regression test dependent objects.
--  plpgsql            | pg_catalog       | 1.0               | 1.0             |                       4 | UP_TO_DATE_OR_DEFAULT | PL/pgSQL procedural language                                           | Review extension release notes and regression test dependent objects.
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
