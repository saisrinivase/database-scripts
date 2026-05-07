/*
PostgreSQL DBA Script: Default Privileges
Purpose: Inspect default privileges that apply to future objects.
Area: Security and Roles
Usage: Helps detect unexpected inherited access.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    r.rolname AS owner_role,
    d.defaclobjtype AS object_type,
    d.defaclacl AS default_acl
FROM pg_default_acl d
LEFT JOIN pg_namespace n
    ON n.oid = d.defaclnamespace
JOIN pg_roles r
    ON r.oid = d.defaclrole
ORDER BY schema_name NULLS FIRST, owner_role, object_type;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | owner_role | object_type | default_acl 
-- -------------+------------+-------------+-------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No matching rows were returned at capture time.
-- - Rerun during peak workload or after seeding representative test cases for non-zero examples.
-- SAMPLE_OUTPUT_END
