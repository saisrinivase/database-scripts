# Object Inventory and Health (360)

Purpose: Deep object-centric administration scripts so teams can quickly choose scripts by object type or issue pattern.

## Coverage

- TABLE, VIEW, MVIEW, TABLESPACE, SEQUENCE, INDEX, TRIGGER, GRANT
- FUNCTION, PROCEDURE, PARTITION, TYPE
- INSERT/COPY activity visibility
- FDW inventory
- Oracle migration mapping for PACKAGE and SYNONYM
- ETL/KETTLE operational signals
- Cross-object issues: missing PK, missing FK index, join-column index gaps, casing risks, and bloat pressure

## Script Map

1. `01_object_type_inventory.sql`
2. `02_table_pk_fk_health.sql`
3. `03_tables_missing_primary_key.sql`
4. `04_missing_fk_supporting_indexes.sql`
5. `05_missing_join_column_indexes.sql`
6. `06_identifier_casing_risks.sql`
7. `07_sequence_ownership_health.sql`
8. `08_trigger_inventory.sql`
9. `09_grant_exposure_audit.sql`
10. `10_function_procedure_inventory.sql`
11. `11_partition_health.sql`
12. `12_user_defined_type_inventory.sql`
13. `13_insert_copy_activity.sql`
14. `14_fdw_inventory.sql`
15. `15_oracle_package_synonym_mapping.sql`
16. `16_kettle_etl_activity_signals.sql`
17. `17_object_bloat_hotspots.sql`
18. `18_object_query_hotspots_pgss.sql`

## Notes

- These scripts are read-only diagnostics.
- `18_object_query_hotspots_pgss.sql` requires `pg_stat_statements`; script returns guidance if extension is missing.
- Oracle `PACKAGE` and `SYNONYM` are modeled as mapping guidance because they are not native PostgreSQL object types.
- Each script includes an embedded sample output section at the bottom.
