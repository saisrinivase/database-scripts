# Object Coverage Matrix

Purpose: Map object-centric administration topics to ready SQL scripts.

## Object and Issue Mapping

| Object or Issue | Primary Scripts | Notes |
|---|---|---|
| TABLE inventory and health | `29_object_inventory_health/01_object_type_inventory.sql`, `29_object_inventory_health/02_table_pk_fk_health.sql` | Includes table counts, PK/FK/index health. |
| VIEW coverage | `29_object_inventory_health/01_object_type_inventory.sql` | User-schema view inventory. |
| MVIEW coverage | `29_object_inventory_health/01_object_type_inventory.sql` | Materialized view inventory. |
| TABLESPACE visibility | `01_database_size/03_tablespaces_size.sql`, `29_object_inventory_health/01_object_type_inventory.sql` | Size + inventory coverage. |
| SEQUENCE ownership and orphan checks | `29_object_inventory_health/07_sequence_ownership_health.sql` | Highlights unowned sequences. |
| INDEX inventory and join/FK index gaps | `03_index_analysis/*.sql`, `29_object_inventory_health/04_missing_fk_supporting_indexes.sql`, `29_object_inventory_health/05_missing_join_column_indexes.sql` | Includes duplicate/unused/missing candidates. |
| TRIGGER inventory | `23_functions_dynamic_sql/04_trigger_function_inventory.sql`, `29_object_inventory_health/08_trigger_inventory.sql` | Includes trigger status and definitions. |
| GRANT posture and exposure | `09_security_roles/03_table_grants_by_role.sql`, `29_object_inventory_health/09_grant_exposure_audit.sql` | PUBLIC and grant-option risk focus. |
| FUNCTION and PROCEDURE diagnostics | `23_functions_dynamic_sql/*.sql`, `29_object_inventory_health/10_function_procedure_inventory.sql` | Includes dynamic SQL and security-definer flags. |
| PARTITION design and health | `05_partitioning/*.sql`, `29_object_inventory_health/11_partition_health.sql` | Includes leaf index coverage. |
| TYPE inventory | `29_object_inventory_health/12_user_defined_type_inventory.sql` | Domain/enum/composite/range visibility. |
| INSERT or COPY ingest visibility | `29_object_inventory_health/13_insert_copy_activity.sql` | COPY progress + table write counters. |
| FDW inventory and federation | `29_object_inventory_health/14_fdw_inventory.sql` | Wrapper/server/mapping/foreign table inventory. |
| QUERY hotspots (object-oriented lens) | `11_performance_tuning/*.sql`, `18_long_queries_full_scans/*.sql`, `28_pgss_resource_attribution/*.sql`, `29_object_inventory_health/18_object_query_hotspots_pgss.sql` | Includes pg_stat_statements-based resource and object token extraction. |
| PK missing | `20_design_matters/01_tables_without_primary_keys.sql`, `29_object_inventory_health/03_tables_missing_primary_key.sql` | Dedicated missing-PK script with starter DDL. |
| FK missing index | `19_dml_optimization/03_missing_fk_supporting_indexes.sql`, `27_high_speed_tuning/04_missing_fk_index_candidates.sql`, `29_object_inventory_health/04_missing_fk_supporting_indexes.sql` | Same problem covered in multiple operational runbooks. |
| Casing risk (quoted identifiers) | `29_object_inventory_health/06_identifier_casing_risks.sql` | Finds mixed/uppercase identifiers. |
| Bloating pressure | `07_vacuum_bloat/*.sql`, `29_object_inventory_health/17_object_bloat_hotspots.sql` | Deep and quick views both available. |
| PACKAGE (Oracle) mapping | `29_object_inventory_health/15_oracle_package_synonym_mapping.sql` | PostgreSQL equivalent: schema + routines. |
| SYNONYM (Oracle) mapping | `29_object_inventory_health/15_oracle_package_synonym_mapping.sql` | PostgreSQL equivalent: views/search_path aliasing. |
| KETTLE operational signals | `29_object_inventory_health/16_kettle_etl_activity_signals.sql` | Detects ETL-like session and role patterns. |

## Notes

- Oracle `PACKAGE` and `SYNONYM` are intentionally treated as migration mapping topics because PostgreSQL does not implement them as native object types.
- `29_object_inventory_health/18_object_query_hotspots_pgss.sql` requires `pg_stat_statements`.
- Coverage target is PostgreSQL `15-18`.
