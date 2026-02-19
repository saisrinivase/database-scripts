/*
Purpose: Show current PostgreSQL version posture and supported target path across PG15-PG18.
Area: Upgrade and Patch Readiness
Usage: Use before planning major version upgrade windows.
*/
WITH version_info AS (
    SELECT
        current_setting('server_version') AS server_version,
        current_setting('server_version_num')::int AS server_version_num,
        (current_setting('server_version_num')::int / 10000)::int AS current_major
),
targets AS (
    SELECT *
    FROM (VALUES (15), (16), (17), (18)) AS t(target_major)
)
SELECT
    v.server_version,
    v.server_version_num,
    v.current_major,
    t.target_major,
    CASE
        WHEN t.target_major = v.current_major THEN 'CURRENT_VERSION'
        WHEN t.target_major > v.current_major THEN 'UPGRADE_CANDIDATE'
        ELSE 'DOWNGRADE_NOT_SUPPORTED'
    END AS path_status,
    CASE
        WHEN t.target_major = v.current_major THEN 'Baseline for patch-level upgrade and validation.'
        WHEN t.target_major > v.current_major THEN 'Validate extension compatibility, collation drift, and plan regression risks before upgrade.'
        ELSE 'Logical migration required; in-place downgrade is not supported.'
    END AS guidance
FROM version_info v
CROSS JOIN targets t
ORDER BY t.target_major;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  server_version  | server_version_num | current_major | target_major |       path_status       |                             guidance                             
-- -----------------+--------------------+---------------+--------------+-------------------------+------------------------------------------------------------------
--  18.0 (Homebrew) |             180000 |            18 |           15 | DOWNGRADE_NOT_SUPPORTED | Logical migration required; in-place downgrade is not supported.
--  18.0 (Homebrew) |             180000 |            18 |           16 | DOWNGRADE_NOT_SUPPORTED | Logical migration required; in-place downgrade is not supported.
--  18.0 (Homebrew) |             180000 |            18 |           17 | DOWNGRADE_NOT_SUPPORTED | Logical migration required; in-place downgrade is not supported.
--  18.0 (Homebrew) |             180000 |            18 |           18 | CURRENT_VERSION         | Baseline for patch-level upgrade and validation.
-- (4 rows)
-- 
-- SAMPLE_OUTPUT_END

