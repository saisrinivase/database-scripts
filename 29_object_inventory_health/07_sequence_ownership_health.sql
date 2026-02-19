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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |              sequence_name              | owner_name | owned_by_schema  |     owned_by_table      | owned_by_column | ownership_status | recommended_action 
------------------+-----------------------------------------+------------+------------------+-------------------------+-----------------+------------------+--------------------
 migration_v2_lab | amount_mapping_risk_id_seq              | saiendla   | migration_v2_lab | amount_mapping_risk     | id              | OWNED            | OK
 migration_v2_lab | bloat_pressure_table_id_seq             | saiendla   | migration_v2_lab | bloat_pressure_table    | id              | OWNED            | OK
 migration_v2_lab | child_events_event_id_seq               | saiendla   | migration_v2_lab | child_events            | event_id        | OWNED            | OK
 migration_v2_lab | customer_contact_compat_customer_id_seq | saiendla   | migration_v2_lab | customer_contact_compat | customer_id     | OWNED            | OK
 migration_v2_lab | order_fact_order_id_seq                 | saiendla   | migration_v2_lab | order_fact              | order_id        | OWNED            | OK
 migration_v2_lab | orphan_order_seq                        | saiendla   | migration_v2_lab | customer_staging_no_pk  | staging_id      | OWNED            | OK
 migration_v2_lab | partitioned_events_event_id_seq         | saiendla   | migration_v2_lab | partitioned_events      | event_id        | OWNED            | OK
 migration_v2_lab | quoted_orders_quoted_order_id_seq       | saiendla   | migration_v2_lab | quoted_orders           | quoted_order_id | OWNED            | OK
 migration_v2_lab | sales_catalog_catalog_id_seq            | saiendla   | migration_v2_lab | sales_catalog           | catalog_id      | OWNED            | OK
 migration_v2_lab | stale_stats_table_id_seq                | saiendla   | migration_v2_lab | stale_stats_table       | id              | OWNED            | OK
 migration_v2_lab | trigger_audit_demo_id_seq               | saiendla   | migration_v2_lab | trigger_audit_demo      | id              | OWNED            | OK
(11 rows)


SAMPLE_OUTPUT_END */
