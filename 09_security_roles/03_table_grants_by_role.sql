/*
PostgreSQL DBA Script: Table Grants By Role
Purpose: Show table-level grants for non-system schemas.
Area: Security and Roles
Usage: Use to audit object privileges by grantee.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    table_schema   |       table_name        |       grantee       | privilege_type | is_grantable 
-- ------------------+-------------------------+---------------------+----------------+--------------
--  dba_metrics      | connection_snapshots    | saiendla            | DELETE         | YES
--  dba_metrics      | connection_snapshots    | saiendla            | INSERT         | YES
--  dba_metrics      | connection_snapshots    | saiendla            | REFERENCES     | YES
--  dba_metrics      | connection_snapshots    | saiendla            | SELECT         | YES
--  dba_metrics      | connection_snapshots    | saiendla            | TRIGGER        | YES
--  dba_metrics      | connection_snapshots    | saiendla            | TRUNCATE       | YES
--  dba_metrics      | connection_snapshots    | saiendla            | UPDATE         | YES
--  dba_metrics      | database_size_snapshots | saiendla            | DELETE         | YES
--  dba_metrics      | database_size_snapshots | saiendla            | INSERT         | YES
--  dba_metrics      | database_size_snapshots | saiendla            | REFERENCES     | YES
--  dba_metrics      | database_size_snapshots | saiendla            | SELECT         | YES
--  dba_metrics      | database_size_snapshots | saiendla            | TRIGGER        | YES
--  dba_metrics      | database_size_snapshots | saiendla            | TRUNCATE       | YES
--  dba_metrics      | database_size_snapshots | saiendla            | UPDATE         | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | DELETE         | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | INSERT         | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | REFERENCES     | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | SELECT         | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | TRIGGER        | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | TRUNCATE       | YES
--  dba_metrics      | index_size_snapshots    | saiendla            | UPDATE         | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | DELETE         | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | INSERT         | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | REFERENCES     | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | SELECT         | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | TRIGGER        | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | TRUNCATE       | YES
--  dba_metrics      | table_size_snapshots    | saiendla            | UPDATE         | YES
--  dba_metrics      | wal_snapshots           | saiendla            | DELETE         | YES
--  dba_metrics      | wal_snapshots           | saiendla            | INSERT         | YES
--  dba_metrics      | wal_snapshots           | saiendla            | REFERENCES     | YES
--  dba_metrics      | wal_snapshots           | saiendla            | SELECT         | YES
--  dba_metrics      | wal_snapshots           | saiendla            | TRIGGER        | YES
--  dba_metrics      | wal_snapshots           | saiendla            | TRUNCATE       | YES
--  dba_metrics      | wal_snapshots           | saiendla            | UPDATE         | YES
--  migration_v1_lab | child_transactions      | saiendla            | DELETE         | YES
--  migration_v1_lab | child_transactions      | saiendla            | INSERT         | YES
--  migration_v1_lab | child_transactions      | saiendla            | REFERENCES     | YES
--  migration_v1_lab | child_transactions      | saiendla            | SELECT         | YES
--  migration_v1_lab | child_transactions      | saiendla            | TRIGGER        | YES
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
