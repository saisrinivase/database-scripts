/*
Purpose: List roles and inherited role memberships.
Area: Security and Roles
Usage: Run as privileged role to see complete membership.
*/
SELECT
    r.rolname AS role_name,
    r.rolcanlogin AS can_login,
    r.rolsuper AS is_superuser,
    r.rolcreatedb AS can_create_db,
    r.rolcreaterole AS can_create_role,
    m.rolname AS member_of_role
FROM pg_roles r
LEFT JOIN pg_auth_members am
    ON am.member = r.oid
LEFT JOIN pg_roles m
    ON m.oid = am.roleid
ORDER BY r.rolname, member_of_role;
