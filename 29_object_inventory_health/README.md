# 29_object_inventory_health

Deep object inventory and health checks for tables, indexes, constraints, PL/SQL, partitions, grants, DB links, and synonyms.

Scripts in this area: `18`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @29_object_inventory_health/<script>.sql`.

## Scripts

- `01_object_type_inventory.sql`
- `02_table_pk_fk_health.sql`
- `03_tables_missing_primary_key.sql`
- `04_missing_fk_supporting_indexes.sql`
- `05_missing_join_column_indexes.sql`
- `06_identifier_casing_risks.sql`
- `07_sequence_ownership_health.sql`
- `08_trigger_inventory.sql`
- `09_grant_exposure_audit.sql`
- `10_function_procedure_inventory.sql`
- `11_partition_health.sql`
- `12_user_defined_type_inventory.sql`
- `13_insert_copy_activity.sql`
- `14_database_link_inventory.sql`
- `15_package_synonym_mapping.sql`
- `16_kettle_etl_activity_signals.sql`
- `17_object_bloat_hotspots.sql`
- `18_object_sql_hotspots.sql`
