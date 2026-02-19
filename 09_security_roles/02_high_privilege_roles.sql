/*
Purpose: Identify highly privileged roles (superuser, replication, bypass RLS).
Area: Security and Roles
Usage: Review regularly for least-privilege compliance.
*/
SELECT
    rolname AS role_name,
    rolsuper AS is_superuser,
    rolreplication AS can_replicate,
    rolbypassrls AS bypasses_row_level_security,
    rolcreaterole AS can_create_roles,
    rolcreatedb AS can_create_databases,
    rolcanlogin AS can_login
FROM pg_roles
WHERE rolsuper
   OR rolreplication
   OR rolbypassrls
   OR rolcreaterole
ORDER BY role_name;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 role_name | is_superuser | can_replicate | bypasses_row_level_security | can_create_roles | can_create_databases | can_login 
-----------+--------------+---------------+-----------------------------+------------------+----------------------+-----------
 postgres  | t            | t             | f                           | t                | t                    | t
 saiendla  | t            | t             | t                           | t                | t                    | t
(2 rows)


SAMPLE_OUTPUT_END */
