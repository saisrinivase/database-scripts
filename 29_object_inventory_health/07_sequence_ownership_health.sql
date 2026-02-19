/*
Purpose: Audit sequence ownership and attachment to table columns.
Area: Object Inventory and Health
Usage: Unowned sequences can become orphaned during refactors or migrations.
*/
WITH sequences AS (
    SELECT
        c.oid AS sequence_oid,
        n.nspname AS schema_name,
        c.relname AS sequence_name,
        pg_get_userbyid(c.relowner) AS owner_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'S'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
ownership AS (
    SELECT
        d.objid AS sequence_oid,
        d.refobjid AS table_oid,
        d.refobjsubid AS attnum,
        d.deptype
    FROM pg_depend d
    WHERE d.classid = 'pg_class'::regclass
      AND d.refclassid = 'pg_class'::regclass
      AND d.deptype IN ('a', 'i')
)
SELECT
    s.schema_name,
    s.sequence_name,
    s.owner_name,
    coalesce(tn.nspname, '') AS owned_by_schema,
    coalesce(tc.relname, '') AS owned_by_table,
    coalesce(a.attname, '') AS owned_by_column,
    CASE WHEN o.sequence_oid IS NULL THEN 'ORPHAN' ELSE 'OWNED' END AS ownership_status,
    CASE
        WHEN o.sequence_oid IS NULL THEN format('ALTER SEQUENCE %I.%I OWNED BY <schema>.<table>.<column>;', s.schema_name, s.sequence_name)
        ELSE 'OK'
    END AS recommended_action
FROM sequences s
LEFT JOIN ownership o
  ON o.sequence_oid = s.sequence_oid
LEFT JOIN pg_class tc
  ON tc.oid = o.table_oid
LEFT JOIN pg_namespace tn
  ON tn.oid = tc.relnamespace
LEFT JOIN pg_attribute a
  ON a.attrelid = tc.oid
 AND a.attnum = o.attnum
ORDER BY ownership_status DESC, s.schema_name, s.sequence_name;
