/*
PostgreSQL DBA Script: Collation Version Mismatch Risk
Purpose: Detect collation version mismatches that can cause index/order behavior drift after OS/DB upgrades.
Area: Upgrade and Patch Readiness
Usage: Rebuild affected indexes after controlled validation when mismatches are found.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH collation_check AS (
    SELECT
        n.nspname AS schema_name,
        c.collname AS collation_name,
        c.collprovider,
        c.collversion AS recorded_version,
        pg_collation_actual_version(c.oid) AS actual_version
    FROM pg_collation c
    JOIN pg_namespace n
      ON n.oid = c.collnamespace
)
SELECT
    schema_name,
    collation_name,
    collprovider,
    coalesce(recorded_version, '(null)') AS recorded_version,
    coalesce(actual_version, '(null)') AS actual_version,
    CASE
        WHEN recorded_version IS NULL OR actual_version IS NULL THEN 'INFO'
        WHEN recorded_version IS DISTINCT FROM actual_version THEN 'MISMATCH'
        ELSE 'MATCH'
    END AS status,
    CASE
        WHEN recorded_version IS NULL OR actual_version IS NULL THEN 'Provider does not expose version or collation uses null metadata.'
        WHEN recorded_version IS DISTINCT FROM actual_version THEN 'Run REINDEX on dependent indexes after regression testing.'
        ELSE 'No collation drift detected.'
    END AS action_hint
FROM collation_check
ORDER BY
    CASE
        WHEN recorded_version IS DISTINCT FROM actual_version
             AND recorded_version IS NOT NULL
             AND actual_version IS NOT NULL THEN 1
        ELSE 2
    END,
    schema_name,
    collation_name;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  schema_name |     collation_name     | collprovider | recorded_version | actual_version | status |                            action_hint                            
-- -------------+------------------------+--------------+------------------+----------------+--------+-------------------------------------------------------------------
--  pg_catalog  | C                      | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | C.UTF-8                | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | POSIX                  | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af-NA-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | af-ZA-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | af-x-icu               | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | af_ZA                  | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af_ZA                  | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af_ZA                  | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af_ZA.ISO8859-1        | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af_ZA.ISO8859-15       | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | af_ZA.UTF-8            | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | agq-CM-x-icu           | i            | 153.128          | 153.128        | MATCH  | No collation drift detected.
--  pg_catalog  | agq-x-icu              | i            | 153.128          | 153.128        | MATCH  | No collation drift detected.
--  pg_catalog  | ak-GH-x-icu            | i            | 153.128          | 153.128        | MATCH  | No collation drift detected.
--  pg_catalog  | ak-x-icu               | i            | 153.128          | 153.128        | MATCH  | No collation drift detected.
--  pg_catalog  | am-ET-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | am-x-icu               | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | am_ET                  | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | am_ET.UTF-8            | c            | (null)           | (null)         | INFO   | Provider does not expose version or collation uses null metadata.
--  pg_catalog  | ar-001-x-icu           | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-AE-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-BH-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-DJ-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-DZ-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-EG-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-EH-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-ER-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-IL-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-IQ-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-JO-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-KM-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-KW-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-LB-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-LY-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-MA-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-MR-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-OM-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-PS-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
--  pg_catalog  | ar-QA-x-icu            | i            | 153.128.47       | 153.128.47     | MATCH  | No collation drift detected.
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
