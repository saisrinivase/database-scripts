/*
PostgreSQL DBA Script: FDW Inventory
Purpose: Inventory FDW objects (wrapper, servers, mappings, and foreign tables).
Area: Object Inventory and Health
Usage: Use for federated query troubleshooting and migration readiness checks.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH wrappers AS (
    SELECT
        fdw.oid,
        fdw.fdwname,
        pg_get_userbyid(fdw.fdwowner) AS owner_name
    FROM pg_foreign_data_wrapper fdw
),
servers AS (
    SELECT
        s.oid,
        s.srvname,
        w.fdwname,
        s.srvtype,
        s.srvversion,
        pg_get_userbyid(s.srvowner) AS owner_name
    FROM pg_foreign_server s
    JOIN wrappers w ON w.oid = s.srvfdw
),
foreign_tables AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        s.srvname
    FROM pg_foreign_table ft
    JOIN pg_class c ON c.oid = ft.ftrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN servers s ON s.oid = ft.ftserver
),
user_mappings AS (
    SELECT
        s.srvname,
        count(*)::bigint AS user_mapping_count
    FROM pg_user_mappings m
    JOIN servers s ON s.oid = m.srvid
    GROUP BY s.srvname
)
SELECT
    'FDW_WRAPPER'::text AS object_type,
    w.fdwname AS object_name,
    w.owner_name,
    NULL::text AS server_name,
    NULL::text AS relation_name,
    NULL::bigint AS mapping_count,
    'Wrapper definition'::text AS notes
FROM wrappers w
UNION ALL
SELECT
    'FDW_SERVER',
    s.fdwname,
    s.owner_name,
    s.srvname,
    coalesce(s.srvtype, ''),
    coalesce(m.user_mapping_count, 0),
    'Server endpoint metadata'
FROM servers s
LEFT JOIN user_mappings m ON m.srvname = s.srvname
UNION ALL
SELECT
    'FOREIGN_TABLE',
    ft.schema_name,
    NULL,
    ft.srvname,
    ft.table_name,
    NULL,
    'Foreign table mapped to server'
FROM foreign_tables ft
UNION ALL
SELECT
    'FDW_STATUS',
    '(none)',
    NULL,
    NULL,
    NULL,
    NULL,
    'No FDW wrapper/server/foreign table configured'
WHERE NOT EXISTS (
    SELECT 1
    FROM wrappers
)
ORDER BY object_type, object_name, server_name, relation_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  object_type | object_name | owner_name | server_name | relation_name | mapping_count |                     notes                      
-- -------------+-------------+------------+-------------+---------------+---------------+------------------------------------------------
--  FDW_STATUS  | (none)      |            |             |               |               | No FDW wrapper/server/foreign table configured
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
