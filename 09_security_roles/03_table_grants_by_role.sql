/*
Purpose: Show table-level grants for non-system schemas.
Area: Security and Roles
Usage: Use to audit object privileges by grantee.
*/
SELECT
    table_schema,
    table_name,
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_schema !~ '^pg_'
  AND table_schema <> 'information_schema'
ORDER BY table_schema, table_name, grantee, privilege_type;
