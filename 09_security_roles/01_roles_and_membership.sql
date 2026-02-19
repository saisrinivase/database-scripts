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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--           role_name          | can_login | is_superuser | can_create_db | can_create_role |    member_of_role    
-- -----------------------------+-----------+--------------+---------------+-----------------+----------------------
--  migration_v2_reader         | t         | f            | f             | f               | 
--  pg_checkpoint               | f         | f            | f             | f               | 
--  pg_create_subscription      | f         | f            | f             | f               | 
--  pg_database_owner           | f         | f            | f             | f               | 
--  pg_execute_server_program   | f         | f            | f             | f               | 
--  pg_maintain                 | f         | f            | f             | f               | 
--  pg_monitor                  | f         | f            | f             | f               | pg_read_all_settings
--  pg_monitor                  | f         | f            | f             | f               | pg_read_all_stats
--  pg_monitor                  | f         | f            | f             | f               | pg_stat_scan_tables
--  pg_read_all_data            | f         | f            | f             | f               | 
--  pg_read_all_settings        | f         | f            | f             | f               | 
--  pg_read_all_stats           | f         | f            | f             | f               | 
--  pg_read_server_files        | f         | f            | f             | f               | 
--  pg_signal_autovacuum_worker | f         | f            | f             | f               | 
--  pg_signal_backend           | f         | f            | f             | f               | 
--  pg_stat_scan_tables         | f         | f            | f             | f               | 
--  pg_use_reserved_connections | f         | f            | f             | f               | 
--  pg_write_all_data           | f         | f            | f             | f               | 
--  pg_write_server_files       | f         | f            | f             | f               | 
--  postgres                    | t         | t            | t             | t               | 
--  saiendla                    | t         | t            | t             | t               | 
-- (21 rows)
-- 
-- SAMPLE_OUTPUT_END

