/*
PostgreSQL DBA Script: Row Level Security Policy Health
Purpose: Detect RLS tables with missing policies, disabled enforcement, owner bypass behavior, broad role scope, and BYPASSRLS roles.
Area: Problem Identification and Internals
Usage: Run in each application database and test flagged objects with the actual application role.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. Table owners normally bypass RLS unless FORCE ROW LEVEL SECURITY is enabled; superusers and BYPASSRLS roles bypass it.
*/
WITH policy_counts AS (
    SELECT
        schemaname,
        tablename,
        count(*) AS policy_count,
        count(*) FILTER (WHERE 'public' = ANY(roles)) AS public_policy_count,
        count(*) FILTER (WHERE cmd = 'ALL') AS all_command_policy_count
    FROM pg_policies
    GROUP BY schemaname, tablename
)
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_get_userbyid(c.relowner) AS table_owner,
    c.relrowsecurity AS rls_enabled,
    c.relforcerowsecurity AS force_rls,
    coalesce(p.policy_count, 0) AS policy_count,
    coalesce(p.public_policy_count, 0) AS public_policy_count,
    coalesce(p.all_command_policy_count, 0) AS all_command_policy_count,
    CASE
        WHEN c.relrowsecurity AND coalesce(p.policy_count, 0) = 0 THEN 'HIGH: RLS_ENABLED_WITH_NO_POLICY_DENIES_NON_OWNER_ACCESS'
        WHEN NOT c.relrowsecurity AND coalesce(p.policy_count, 0) > 0 THEN 'HIGH: POLICIES_EXIST_BUT_RLS_DISABLED'
        WHEN c.relrowsecurity AND NOT c.relforcerowsecurity THEN 'REVIEW: TABLE_OWNER_BYPASSES_RLS'
        WHEN coalesce(p.public_policy_count, 0) > 0 THEN 'REVIEW: POLICY_APPLIES_TO_PUBLIC'
        ELSE 'READY_FOR_ROLE_TEST'
    END AS diagnosis,
    'SET ROLE to the application role and test SELECT, INSERT, UPDATE, and DELETE paths in a rollback-only test transaction.' AS next_action
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN policy_counts p ON p.schemaname = n.nspname AND p.tablename = c.relname
WHERE c.relkind IN ('r', 'p')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND (c.relrowsecurity OR c.relforcerowsecurity OR coalesce(p.policy_count, 0) > 0)
ORDER BY diagnosis, n.nspname, c.relname;

SELECT
    schemaname AS schema_name,
    tablename AS table_name,
    policyname AS policy_name,
    permissive,
    roles,
    cmd,
    qual AS using_expression,
    with_check AS with_check_expression,
    CASE
        WHEN qual IS NULL AND cmd IN ('SELECT', 'UPDATE', 'DELETE', 'ALL') THEN 'REVIEW_USING_EXPRESSION'
        WHEN with_check IS NULL AND cmd IN ('INSERT', 'UPDATE', 'ALL') THEN 'REVIEW_WITH_CHECK_EXPRESSION'
        WHEN 'public' = ANY(roles) THEN 'REVIEW_PUBLIC_ROLE_SCOPE'
        ELSE 'POLICY_DEFINED'
    END AS diagnosis
FROM pg_policies
ORDER BY schemaname, tablename, policyname;

SELECT
    rolname,
    rolsuper,
    rolbypassrls,
    rolcanlogin,
    CASE
        WHEN rolsuper THEN 'SUPERUSER_BYPASSES_RLS'
        WHEN rolbypassrls THEN 'ROLE_BYPASSES_RLS'
        ELSE 'NORMAL_RLS_SUBJECT'
    END AS rls_behavior
FROM pg_roles
WHERE rolsuper OR rolbypassrls
ORDER BY rolsuper DESC, rolbypassrls DESC, rolname;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | table_name | rls_enabled | force_rls | policy_count | diagnosis | next_action
-- schema_name | table_name | policy_name | roles | cmd | using_expression | with_check_expression | diagnosis
-- rolname | rolsuper | rolbypassrls | rolcanlogin | rls_behavior
-- SAMPLE_OUTPUT_END
