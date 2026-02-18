/*
Purpose: Inspect default privileges that apply to future objects.
Area: Security and Roles
Usage: Helps detect unexpected inherited access.
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
