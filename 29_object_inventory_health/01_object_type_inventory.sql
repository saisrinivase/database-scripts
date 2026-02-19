/*
Purpose: Provide a one-shot inventory of core object types and migration-mapped object equivalents.
Area: Object Inventory and Health
Usage: Run first to understand object landscape and missing object classes.
*/
WITH user_schemas AS (
    SELECT oid, nspname
    FROM pg_namespace
    WHERE nspname !~ '^pg_'
      AND nspname <> 'information_schema'
),
app_sessions AS (
    SELECT count(*)::bigint AS kettle_like_sessions
    FROM pg_stat_activity
    WHERE application_name ~* '(kettle|pentaho|spoon|pan|kitchen|etl)'
)
SELECT
    object_group,
    object_type,
    object_count,
    CASE WHEN object_count > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END AS status,
    notes
FROM (
    SELECT 'Core Objects'::text AS object_group,
           'TABLE'::text AS object_type,
           count(*)::bigint AS object_count,
           'User schemas only'::text AS notes
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'r'

    UNION ALL

    SELECT 'Core Objects',
           'VIEW',
           count(*)::bigint,
           'User schemas only'
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'v'

    UNION ALL

    SELECT 'Core Objects',
           'MVIEW',
           count(*)::bigint,
           'User schemas only'
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'm'

    UNION ALL

    SELECT 'Storage',
           'TABLESPACE',
           count(*)::bigint,
           'Includes default + custom tablespaces'
    FROM pg_tablespace

    UNION ALL

    SELECT 'Core Objects',
           'SEQUENCE',
           count(*)::bigint,
           'User schemas only'
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'S'

    UNION ALL

    SELECT 'Core Objects',
           'INDEX',
           count(*)::bigint,
           'User schemas only'
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'i'

    UNION ALL

    SELECT 'Programmability',
           'TRIGGER',
           count(*)::bigint,
           'User-defined triggers'
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE NOT t.tgisinternal

    UNION ALL

    SELECT 'Security',
           'GRANT_TABLE_PRIVILEGE',
           count(*)::bigint,
           'Rows from information_schema.table_privileges'
    FROM information_schema.table_privileges
    WHERE table_schema !~ '^pg_'
      AND table_schema <> 'information_schema'

    UNION ALL

    SELECT 'Programmability',
           'FUNCTION',
           count(*)::bigint,
           'prokind=f in user schemas'
    FROM pg_proc p
    JOIN user_schemas s ON s.oid = p.pronamespace
    WHERE p.prokind = 'f'

    UNION ALL

    SELECT 'Programmability',
           'PROCEDURE',
           count(*)::bigint,
           'prokind=p in user schemas'
    FROM pg_proc p
    JOIN user_schemas s ON s.oid = p.pronamespace
    WHERE p.prokind = 'p'

    UNION ALL

    SELECT 'Partitioning',
           'PARTITIONED_TABLE',
           count(*)::bigint,
           'relkind=p'
    FROM pg_class c
    JOIN user_schemas s ON s.oid = c.relnamespace
    WHERE c.relkind = 'p'

    UNION ALL

    SELECT 'Partitioning',
           'PARTITION',
           count(*)::bigint,
           'Tables participating as partition child'
    FROM pg_inherits

    UNION ALL

    SELECT 'Schema Modeling',
           'TYPE',
           count(*)::bigint,
           'User-defined types'
    FROM pg_type t
    JOIN user_schemas s ON s.oid = t.typnamespace
    LEFT JOIN pg_class tc ON tc.oid = t.typrelid
    WHERE t.typtype IN ('c', 'd', 'e', 'm', 'r')
      AND (t.typtype <> 'c' OR tc.relkind = 'c')

    UNION ALL

    SELECT 'Federation',
           'FDW_SERVER',
           count(*)::bigint,
           'Foreign servers configured'
    FROM pg_foreign_server

    UNION ALL

    SELECT 'Migration Mapping',
           'PACKAGE',
           0::bigint,
           'Not native in PostgreSQL; map to schema + functions/procedures'

    UNION ALL

    SELECT 'Migration Mapping',
           'SYNONYM',
           0::bigint,
           'Not native in PostgreSQL; map to views/search_path patterns'

    UNION ALL

    SELECT 'External Integration',
           'KETTLE',
           a.kettle_like_sessions,
           'Detected via application_name patterns in pg_stat_activity'
    FROM app_sessions a
) x
ORDER BY object_group, object_type;
