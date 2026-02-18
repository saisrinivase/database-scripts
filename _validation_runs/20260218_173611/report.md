# Script Validation Report

- Validation database: script_validation_20260218_172749
- Run directory: /Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/_validation_runs/20260218_173611
- Total scripts: 136
- Passed: 136
- Failed: 0

## Result Table

| Status | Exit | Script | Output |
|---|---:|---|---|
| PASS | 0 | 00_environment/01_server_instance_overview.sql | out/00_environment/01_server_instance_overview.out.txt |
| PASS | 0 | 00_environment/02_extensions_installed.sql | out/00_environment/02_extensions_installed.out.txt |
| PASS | 0 | 00_environment/03_database_catalog_overview.sql | out/00_environment/03_database_catalog_overview.out.txt |
| PASS | 0 | 01_database_size/01_databases_size.sql | out/01_database_size/01_databases_size.out.txt |
| PASS | 0 | 01_database_size/02_current_database_size_breakdown.sql | out/01_database_size/02_current_database_size_breakdown.out.txt |
| PASS | 0 | 01_database_size/03_tablespaces_size.sql | out/01_database_size/03_tablespaces_size.out.txt |
| PASS | 0 | 02_table_storage/01_table_size_breakdown.sql | out/02_table_storage/01_table_size_breakdown.out.txt |
| PASS | 0 | 02_table_storage/02_top_largest_tables.sql | out/02_table_storage/02_top_largest_tables.out.txt |
| PASS | 0 | 02_table_storage/03_table_growth_baseline_snapshot.sql | out/02_table_storage/03_table_growth_baseline_snapshot.out.txt |
| PASS | 0 | 02_table_storage/04_relation_storage_parameters.sql | out/02_table_storage/04_relation_storage_parameters.out.txt |
| PASS | 0 | 03_index_analysis/01_index_size_and_usage.sql | out/03_index_analysis/01_index_size_and_usage.out.txt |
| PASS | 0 | 03_index_analysis/02_unused_indexes_candidates.sql | out/03_index_analysis/02_unused_indexes_candidates.out.txt |
| PASS | 0 | 03_index_analysis/03_duplicate_indexes.sql | out/03_index_analysis/03_duplicate_indexes.out.txt |
| PASS | 0 | 03_index_analysis/04_index_maintenance_candidates.sql | out/03_index_analysis/04_index_maintenance_candidates.out.txt |
| PASS | 0 | 04_toast_lob_blob/01_tables_with_toast.sql | out/04_toast_lob_blob/01_tables_with_toast.out.txt |
| PASS | 0 | 04_toast_lob_blob/02_toast_heavy_tables.sql | out/04_toast_lob_blob/02_toast_heavy_tables.out.txt |
| PASS | 0 | 04_toast_lob_blob/03_large_objects_summary.sql | out/04_toast_lob_blob/03_large_objects_summary.out.txt |
| PASS | 0 | 04_toast_lob_blob/04_top_large_objects.sql | out/04_toast_lob_blob/04_top_large_objects.out.txt |
| PASS | 0 | 05_partitioning/01_partitioned_tables_overview.sql | out/05_partitioning/01_partitioned_tables_overview.out.txt |
| PASS | 0 | 05_partitioning/02_partition_size_distribution.sql | out/05_partitioning/02_partition_size_distribution.out.txt |
| PASS | 0 | 05_partitioning/03_partitions_without_indexes.sql | out/05_partitioning/03_partitions_without_indexes.out.txt |
| PASS | 0 | 05_partitioning/04_partitioning_recommendation_candidates.sql | out/05_partitioning/04_partitioning_recommendation_candidates.out.txt |
| PASS | 0 | 06_activity_locks/01_active_sessions.sql | out/06_activity_locks/01_active_sessions.out.txt |
| PASS | 0 | 06_activity_locks/02_blocking_and_blocked_sessions.sql | out/06_activity_locks/02_blocking_and_blocked_sessions.out.txt |
| PASS | 0 | 06_activity_locks/03_long_running_transactions.sql | out/06_activity_locks/03_long_running_transactions.out.txt |
| PASS | 0 | 06_activity_locks/04_wait_events_summary.sql | out/06_activity_locks/04_wait_events_summary.out.txt |
| PASS | 0 | 07_vacuum_bloat/01_table_bloat_estimate.sql | out/07_vacuum_bloat/01_table_bloat_estimate.out.txt |
| PASS | 0 | 07_vacuum_bloat/02_autovacuum_table_status.sql | out/07_vacuum_bloat/02_autovacuum_table_status.out.txt |
| PASS | 0 | 07_vacuum_bloat/03_freeze_age_risk.sql | out/07_vacuum_bloat/03_freeze_age_risk.out.txt |
| PASS | 0 | 07_vacuum_bloat/04_dead_tuples_hotspots.sql | out/07_vacuum_bloat/04_dead_tuples_hotspots.out.txt |
| PASS | 0 | 07_vacuum_bloat/05_vacuum_progress.sql | out/07_vacuum_bloat/05_vacuum_progress.out.txt |
| PASS | 0 | 08_replication_ha/01_primary_replication_status.sql | out/08_replication_ha/01_primary_replication_status.out.txt |
| PASS | 0 | 08_replication_ha/02_standby_replay_status.sql | out/08_replication_ha/02_standby_replay_status.out.txt |
| PASS | 0 | 08_replication_ha/03_replication_slots_health.sql | out/08_replication_ha/03_replication_slots_health.out.txt |
| PASS | 0 | 08_replication_ha/04_wal_generation_rate.sql | out/08_replication_ha/04_wal_generation_rate.out.txt |
| PASS | 0 | 09_security_roles/01_roles_and_membership.sql | out/09_security_roles/01_roles_and_membership.out.txt |
| PASS | 0 | 09_security_roles/02_high_privilege_roles.sql | out/09_security_roles/02_high_privilege_roles.out.txt |
| PASS | 0 | 09_security_roles/03_table_grants_by_role.sql | out/09_security_roles/03_table_grants_by_role.out.txt |
| PASS | 0 | 09_security_roles/04_default_privileges.sql | out/09_security_roles/04_default_privileges.out.txt |
| PASS | 0 | 10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql | out/10_maintenance_monitoring/01_bgwriter_checkpoint_stats.out.txt |
| PASS | 0 | 10_maintenance_monitoring/02_cache_hit_ratio.sql | out/10_maintenance_monitoring/02_cache_hit_ratio.out.txt |
| PASS | 0 | 10_maintenance_monitoring/03_top_statements_pg_stat_statements.sql | out/10_maintenance_monitoring/03_top_statements_pg_stat_statements.out.txt |
| PASS | 0 | 10_maintenance_monitoring/04_non_default_config.sql | out/10_maintenance_monitoring/04_non_default_config.out.txt |
| PASS | 0 | 10_maintenance_monitoring/05_connection_capacity.sql | out/10_maintenance_monitoring/05_connection_capacity.out.txt |
| PASS | 0 | 11_performance_tuning/01_top_queries_by_total_exec_time.sql | out/11_performance_tuning/01_top_queries_by_total_exec_time.out.txt |
| PASS | 0 | 11_performance_tuning/02_top_queries_by_mean_exec_time.sql | out/11_performance_tuning/02_top_queries_by_mean_exec_time.out.txt |
| PASS | 0 | 11_performance_tuning/03_temp_file_heavy_queries.sql | out/11_performance_tuning/03_temp_file_heavy_queries.out.txt |
| PASS | 0 | 11_performance_tuning/04_io_bound_query_candidates.sql | out/11_performance_tuning/04_io_bound_query_candidates.out.txt |
| PASS | 0 | 11_performance_tuning/05_performance_related_settings.sql | out/11_performance_tuning/05_performance_related_settings.out.txt |
| PASS | 0 | 11_performance_tuning/06_function_hotspots.sql | out/11_performance_tuning/06_function_hotspots.out.txt |
| PASS | 0 | 12_planner_statistics/01_tables_needing_analyze.sql | out/12_planner_statistics/01_tables_needing_analyze.out.txt |
| PASS | 0 | 12_planner_statistics/02_seq_scan_hotspots.sql | out/12_planner_statistics/02_seq_scan_hotspots.out.txt |
| PASS | 0 | 12_planner_statistics/03_column_stats_profile.sql | out/12_planner_statistics/03_column_stats_profile.out.txt |
| PASS | 0 | 12_planner_statistics/04_extended_stats_candidates.sql | out/12_planner_statistics/04_extended_stats_candidates.out.txt |
| PASS | 0 | 12_planner_statistics/05_autovacuum_analyze_settings_by_table.sql | out/12_planner_statistics/05_autovacuum_analyze_settings_by_table.out.txt |
| PASS | 0 | 12_planner_statistics/06_planner_cost_settings.sql | out/12_planner_statistics/06_planner_cost_settings.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/01_database_io_profile.sql | out/13_io_wal_checkpoints/01_database_io_profile.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/02_table_io_hotspots.sql | out/13_io_wal_checkpoints/02_table_io_hotspots.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/03_index_io_hotspots.sql | out/13_io_wal_checkpoints/03_index_io_hotspots.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/04_wal_archiver_health.sql | out/13_io_wal_checkpoints/04_wal_archiver_health.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql | out/13_io_wal_checkpoints/05_checkpoint_pressure_indicators.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/06_temp_file_usage_by_database.sql | out/13_io_wal_checkpoints/06_temp_file_usage_by_database.out.txt |
| PASS | 0 | 13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql | out/13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.out.txt |
| PASS | 0 | 14_connection_workload/01_connections_by_user_app_db.sql | out/14_connection_workload/01_connections_by_user_app_db.out.txt |
| PASS | 0 | 14_connection_workload/02_idle_in_transaction_risk.sql | out/14_connection_workload/02_idle_in_transaction_risk.out.txt |
| PASS | 0 | 14_connection_workload/03_connection_state_distribution.sql | out/14_connection_workload/03_connection_state_distribution.out.txt |
| PASS | 0 | 14_connection_workload/04_role_connection_limit_risk.sql | out/14_connection_workload/04_role_connection_limit_risk.out.txt |
| PASS | 0 | 14_connection_workload/05_backend_type_distribution.sql | out/14_connection_workload/05_backend_type_distribution.out.txt |
| PASS | 0 | 14_connection_workload/06_prepared_transactions_status.sql | out/14_connection_workload/06_prepared_transactions_status.out.txt |
| PASS | 0 | 15_capacity_forecasting/01_create_capacity_repository.sql | out/15_capacity_forecasting/01_create_capacity_repository.out.txt |
| PASS | 0 | 15_capacity_forecasting/02_capture_database_size_snapshot.sql | out/15_capacity_forecasting/02_capture_database_size_snapshot.out.txt |
| PASS | 0 | 15_capacity_forecasting/03_capture_table_size_snapshot.sql | out/15_capacity_forecasting/03_capture_table_size_snapshot.out.txt |
| PASS | 0 | 15_capacity_forecasting/04_capture_index_size_snapshot.sql | out/15_capacity_forecasting/04_capture_index_size_snapshot.out.txt |
| PASS | 0 | 15_capacity_forecasting/05_capture_connection_snapshot.sql | out/15_capacity_forecasting/05_capture_connection_snapshot.out.txt |
| PASS | 0 | 15_capacity_forecasting/06_capture_wal_snapshot.sql | out/15_capacity_forecasting/06_capture_wal_snapshot.out.txt |
| PASS | 0 | 15_capacity_forecasting/07_database_growth_report.sql | out/15_capacity_forecasting/07_database_growth_report.out.txt |
| PASS | 0 | 15_capacity_forecasting/08_table_growth_report.sql | out/15_capacity_forecasting/08_table_growth_report.out.txt |
| PASS | 0 | 16_internals_deep_dive/01_database_xid_multixact_age.sql | out/16_internals_deep_dive/01_database_xid_multixact_age.out.txt |
| PASS | 0 | 16_internals_deep_dive/02_relation_filenode_mapping.sql | out/16_internals_deep_dive/02_relation_filenode_mapping.out.txt |
| PASS | 0 | 16_internals_deep_dive/03_system_catalog_size_profile.sql | out/16_internals_deep_dive/03_system_catalog_size_profile.out.txt |
| PASS | 0 | 16_internals_deep_dive/04_dependency_fanout_objects.sql | out/16_internals_deep_dive/04_dependency_fanout_objects.out.txt |
| PASS | 0 | 16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql | out/16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.out.txt |
| PASS | 0 | 16_internals_deep_dive/06_visibility_and_freeze_profile.sql | out/16_internals_deep_dive/06_visibility_and_freeze_profile.out.txt |
| PASS | 0 | 17_execution_plans/01_plan_capture_prerequisites.sql | out/17_execution_plans/01_plan_capture_prerequisites.out.txt |
| PASS | 0 | 17_execution_plans/02_explain_analyze_template.sql | out/17_execution_plans/02_explain_analyze_template.out.txt |
| PASS | 0 | 17_execution_plans/03_generate_explain_for_top_queries.sql | out/17_execution_plans/03_generate_explain_for_top_queries.out.txt |
| PASS | 0 | 17_execution_plans/04_plan_red_flag_candidates.sql | out/17_execution_plans/04_plan_red_flag_candidates.out.txt |
| PASS | 0 | 18_long_queries_full_scans/01_active_long_queries.sql | out/18_long_queries_full_scans/01_active_long_queries.out.txt |
| PASS | 0 | 18_long_queries_full_scans/02_long_queries_from_statements.sql | out/18_long_queries_full_scans/02_long_queries_from_statements.out.txt |
| PASS | 0 | 18_long_queries_full_scans/03_short_vs_long_query_distribution.sql | out/18_long_queries_full_scans/03_short_vs_long_query_distribution.out.txt |
| PASS | 0 | 18_long_queries_full_scans/04_full_scan_hotspot_tables.sql | out/18_long_queries_full_scans/04_full_scan_hotspot_tables.out.txt |
| PASS | 0 | 19_dml_optimization/01_write_heavy_tables.sql | out/19_dml_optimization/01_write_heavy_tables.out.txt |
| PASS | 0 | 19_dml_optimization/02_hot_update_efficiency.sql | out/19_dml_optimization/02_hot_update_efficiency.out.txt |
| PASS | 0 | 19_dml_optimization/03_missing_fk_supporting_indexes.sql | out/19_dml_optimization/03_missing_fk_supporting_indexes.out.txt |
| PASS | 0 | 19_dml_optimization/04_dml_bloat_pressure.sql | out/19_dml_optimization/04_dml_bloat_pressure.out.txt |
| PASS | 0 | 20_design_matters/01_tables_without_primary_keys.sql | out/20_design_matters/01_tables_without_primary_keys.out.txt |
| PASS | 0 | 20_design_matters/02_wide_tables_profile.sql | out/20_design_matters/02_wide_tables_profile.out.txt |
| PASS | 0 | 20_design_matters/03_overindexed_tables.sql | out/20_design_matters/03_overindexed_tables.out.txt |
| PASS | 0 | 20_design_matters/04_high_nullability_columns.sql | out/20_design_matters/04_high_nullability_columns.out.txt |
| PASS | 0 | 21_configuration_parameters/01_core_performance_settings.sql | out/21_configuration_parameters/01_core_performance_settings.out.txt |
| PASS | 0 | 21_configuration_parameters/02_wal_checkpoint_settings.sql | out/21_configuration_parameters/02_wal_checkpoint_settings.out.txt |
| PASS | 0 | 21_configuration_parameters/03_autovacuum_settings.sql | out/21_configuration_parameters/03_autovacuum_settings.out.txt |
| PASS | 0 | 21_configuration_parameters/04_connection_timeout_settings.sql | out/21_configuration_parameters/04_connection_timeout_settings.out.txt |
| PASS | 0 | 22_application_orm_performance/01_n_plus_one_query_candidates.sql | out/22_application_orm_performance/01_n_plus_one_query_candidates.out.txt |
| PASS | 0 | 22_application_orm_performance/02_select_star_candidates.sql | out/22_application_orm_performance/02_select_star_candidates.out.txt |
| PASS | 0 | 22_application_orm_performance/03_chatty_small_result_queries.sql | out/22_application_orm_performance/03_chatty_small_result_queries.out.txt |
| PASS | 0 | 22_application_orm_performance/04_app_idle_in_transaction_risk.sql | out/22_application_orm_performance/04_app_idle_in_transaction_risk.out.txt |
| PASS | 0 | 23_functions_dynamic_sql/01_function_execution_hotspots.sql | out/23_functions_dynamic_sql/01_function_execution_hotspots.out.txt |
| PASS | 0 | 23_functions_dynamic_sql/02_dynamic_sql_function_inventory.sql | out/23_functions_dynamic_sql/02_dynamic_sql_function_inventory.out.txt |
| PASS | 0 | 23_functions_dynamic_sql/03_volatile_and_security_definer_functions.sql | out/23_functions_dynamic_sql/03_volatile_and_security_definer_functions.out.txt |
| PASS | 0 | 23_functions_dynamic_sql/04_trigger_function_inventory.sql | out/23_functions_dynamic_sql/04_trigger_function_inventory.out.txt |
| PASS | 0 | 24_complex_filter_search/01_like_ilike_query_candidates.sql | out/24_complex_filter_search/01_like_ilike_query_candidates.out.txt |
| PASS | 0 | 24_complex_filter_search/02_jsonb_array_column_inventory.sql | out/24_complex_filter_search/02_jsonb_array_column_inventory.out.txt |
| PASS | 0 | 24_complex_filter_search/03_gin_gist_brin_index_inventory.sql | out/24_complex_filter_search/03_gin_gist_brin_index_inventory.out.txt |
| PASS | 0 | 24_complex_filter_search/04_full_text_search_inventory.sql | out/24_complex_filter_search/04_full_text_search_inventory.out.txt |
| PASS | 0 | 25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.sql | out/25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.out.txt |
| PASS | 0 | 25_oltp_olap_goals/02_oltp_latency_goal_candidates.sql | out/25_oltp_olap_goals/02_oltp_latency_goal_candidates.out.txt |
| PASS | 0 | 25_oltp_olap_goals/03_olap_throughput_candidates.sql | out/25_oltp_olap_goals/03_olap_throughput_candidates.out.txt |
| PASS | 0 | 25_oltp_olap_goals/04_mixed_workload_pressure.sql | out/25_oltp_olap_goals/04_mixed_workload_pressure.out.txt |
| PASS | 0 | 26_physical_cloud_diagnostics/01_instance_platform_fingerprint.sql | out/26_physical_cloud_diagnostics/01_instance_platform_fingerprint.out.txt |
| PASS | 0 | 26_physical_cloud_diagnostics/02_io_latency_profile.sql | out/26_physical_cloud_diagnostics/02_io_latency_profile.out.txt |
| PASS | 0 | 26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql | out/26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.out.txt |
| PASS | 0 | 26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.sql | out/26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.out.txt |
| PASS | 0 | 27_high_speed_tuning/01_bottleneck_overview_dashboard.sql | out/27_high_speed_tuning/01_bottleneck_overview_dashboard.out.txt |
| PASS | 0 | 27_high_speed_tuning/02_waits_and_blocking_details.sql | out/27_high_speed_tuning/02_waits_and_blocking_details.out.txt |
| PASS | 0 | 27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql | out/27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.out.txt |
| PASS | 0 | 27_high_speed_tuning/04_missing_fk_index_candidates.sql | out/27_high_speed_tuning/04_missing_fk_index_candidates.out.txt |
| PASS | 0 | 27_high_speed_tuning/05_parameter_tuning_advisor.sql | out/27_high_speed_tuning/05_parameter_tuning_advisor.out.txt |
| PASS | 0 | 27_high_speed_tuning/06_query_tuning_action_queue.sql | out/27_high_speed_tuning/06_query_tuning_action_queue.out.txt |
| PASS | 0 | 27_migration_validation/01_oracle_to_postgres_360_health_report.sql | out/27_migration_validation/01_oracle_to_postgres_360_health_report.out.txt |
| PASS | 0 | 27_migration_validation/02_seed_v1_test_issues.sql | out/27_migration_validation/02_seed_v1_test_issues.out.txt |
| PASS | 0 | 27_migration_validation/03_fix_v1_test_issues.sql | out/27_migration_validation/03_fix_v1_test_issues.out.txt |
| PASS | 0 | 28_pgss_resource_attribution/01_pgss_query_resource_percent.sql | out/28_pgss_resource_attribution/01_pgss_query_resource_percent.out.txt |
| PASS | 0 | 28_pgss_resource_attribution/02_pgss_resource_percent_by_database.sql | out/28_pgss_resource_attribution/02_pgss_resource_percent_by_database.out.txt |
| PASS | 0 | 28_pgss_resource_attribution/03_pgss_resource_percent_by_user.sql | out/28_pgss_resource_attribution/03_pgss_resource_percent_by_user.out.txt |
| PASS | 0 | 28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.sql | out/28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.out.txt |

## Sample Output (Per Script)

### 00_environment/01_server_instance_overview.sql
- Status: PASS
- Exit code: 0
- Output file: out/00_environment/01_server_instance_overview.out.txt

```text
           database_name           | login_role |                                                        server_version                                                        | server_version_num |     postmaster_start_time     |    instance_uptime     |         data_directory          |                   config_file                   |                  hba_file                   
-----------------------------------+------------+------------------------------------------------------------------------------------------------------------------------------+--------------------+-------------------------------+------------------------+---------------------------------+-------------------------------------------------+---------------------------------------------
 script_validation_20260218_172749 | saiendla   | PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit | 180000             | 2026-02-10 09:32:09.191307-05 | 8 days 08:04:02.697281 | /opt/homebrew/var/postgresql@18 | /opt/homebrew/var/postgresql@18/postgresql.conf | /opt/homebrew/var/postgresql@18/pg_hba.conf
(1 row)

```

### 00_environment/02_extensions_installed.sql
- Status: PASS
- Exit code: 0
- Output file: out/00_environment/02_extensions_installed.out.txt

```text
   extension_name   | extension_version | extension_schema | extension_owner 
--------------------+-------------------+------------------+-----------------
 pg_stat_statements | 1.12              | public           | saiendla
 plpgsql            | 1.0               | pg_catalog       | saiendla
(2 rows)

```

### 00_environment/03_database_catalog_overview.sql
- Status: PASS
- Exit code: 0
- Output file: out/00_environment/03_database_catalog_overview.out.txt

```text
    object_type     | object_count 
--------------------+--------------
 indexes            |           34
 partitioned tables |            0
 schemas            |            3
 tables             |           27
 views              |            2
(5 rows)

```

### 01_database_size/01_databases_size.sql
- Status: PASS
- Exit code: 0
- Output file: out/01_database_size/01_databases_size.out.txt

```text
           database_name           | size_bytes  | size_pretty 
-----------------------------------+-------------+-------------
 pgbench_test                      | 32018454207 | 30 GB
 script_validation_20260218_172749 |   436623039 | 416 MB
 perf_test                         |   436410047 | 416 MB
 hypopg_lab                        |    36173503 | 34 MB
 postgres                          |     8140479 | 7950 kB
 appdb                             |     8066751 | 7878 kB
 template1                         |     8033983 | 7846 kB
 template0                         |     7791119 | 7609 kB
(8 rows)

```

### 01_database_size/02_current_database_size_breakdown.sql
- Status: PASS
- Exit code: 0
- Output file: out/01_database_size/02_current_database_size_breakdown.out.txt

```text
 database_total_bytes | database_total_pretty | table_heap_bytes | table_heap_pretty | indexes_bytes | indexes_pretty | toast_bytes | toast_pretty 
----------------------+-----------------------+------------------+-------------------+---------------+----------------+-------------+--------------
            436623039 | 416 MB                |          2277376 | 2224 kB           |     425123840 | 405 MB         |      172032 | 168 kB
(1 row)

```

### 01_database_size/03_tablespaces_size.sql
- Status: PASS
- Exit code: 0
- Output file: out/01_database_size/03_tablespaces_size.out.txt

```text
 tablespace_name | size_bytes  | size_pretty 
-----------------+-------------+-------------
 pg_default      | 32959781800 | 31 GB
 pg_global       |      586116 | 572 kB
(2 rows)

```

### 02_table_storage/01_table_size_breakdown.sql
- Status: PASS
- Exit code: 0
- Output file: out/02_table_storage/01_table_size_breakdown.out.txt

```text
 schema_name |       table_name        | heap_bytes | index_bytes | toast_bytes | total_bytes | total_pretty 
-------------+-------------------------+------------+-------------+-------------+-------------+--------------
 perf        | order_items             |          0 |   122609664 |           0 |   122626048 | 117 MB
 perf        | app_events              |          0 |    99246080 |        8192 |    99270656 | 95 MB
 perf        | payments                |          0 |    87064576 |           0 |    87080960 | 83 MB
 perf        | orders                  |          0 |    78495744 |           0 |    78512128 | 75 MB
 perf        | shipments               |          0 |    19013632 |        8192 |    19038208 | 18 MB
 perf        | users                   |          0 |     4808704 |        8192 |     4833280 | 4720 kB
 public      | demo_users              |    2220032 |     2244608 |        8192 |     4505600 | 4400 kB
 perf        | inventory               |          0 |     3481600 |           0 |     3497984 | 3416 kB
 perf        | product_categories      |          0 |     2686976 |           0 |     2703360 | 2640 kB
 perf        | products                |          0 |     2260992 |        8192 |     2285568 | 2232 kB
 perf        | addresses               |          0 |     1589248 |        8192 |     1613824 | 1576 kB
 perf        | sessions                |          0 |     1359872 |           0 |     1376256 | 1344 kB
 perf        | feature_flags           |          0 |       98304 |        8192 |      122880 | 120 kB
 perf        | categories              |          0 |       73728 |        8192 |       98304 | 96 kB
 dba_metrics | index_size_snapshots    |      16384 |           0 |        8192 |       49152 | 48 kB
 perf        | tenants                 |       8192 |       16384 |        8192 |       32768 | 32 kB
 perf        | audit_log               |          0 |       16384 |        8192 |       24576 | 24 kB
 perf        | documents               |          0 |       16384 |        8192 |       24576 | 24 kB
```

### 02_table_storage/02_top_largest_tables.sql
- Status: PASS
- Exit code: 0
- Output file: out/02_table_storage/02_top_largest_tables.out.txt

```text
 schema_name |       table_name        | total_bytes | total_pretty | estimated_live_rows | estimated_dead_rows 
-------------+-------------------------+-------------+--------------+---------------------+---------------------
 perf        | order_items             |   122626048 | 117 MB       |                   0 |                   0
 perf        | app_events              |    99270656 | 95 MB        |                   0 |                   0
 perf        | payments                |    87080960 | 83 MB        |                   0 |                   0
 perf        | orders                  |    78512128 | 75 MB        |                   0 |                   0
 perf        | shipments               |    19038208 | 18 MB        |                   0 |                   0
 perf        | users                   |     4833280 | 4720 kB      |                   0 |                   0
 public      | demo_users              |     4505600 | 4400 kB      |                   0 |                   0
 perf        | inventory               |     3497984 | 3416 kB      |                   0 |                   0
 perf        | product_categories      |     2703360 | 2640 kB      |                   0 |                   0
 perf        | products                |     2285568 | 2232 kB      |                   0 |                   0
 perf        | addresses               |     1613824 | 1576 kB      |                   0 |                   0
 perf        | sessions                |     1376256 | 1344 kB      |                   0 |                   0
 perf        | feature_flags           |      122880 | 120 kB       |                   0 |                   0
 perf        | categories              |       98304 | 96 kB        |                   0 |                   0
 dba_metrics | index_size_snapshots    |       49152 | 48 kB        |                 102 |                   0
 perf        | tenants                 |       32768 | 32 kB        |                   0 |                   0
 perf        | audit_log               |       24576 | 24 kB        |                   0 |                   0
 perf        | documents               |       24576 | 24 kB        |                   0 |                   0
```

### 02_table_storage/03_table_growth_baseline_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/02_table_storage/03_table_growth_baseline_snapshot.out.txt

```text
          captured_at          | schema_name |       table_name        | estimated_live_rows | estimated_dead_rows | total_bytes | total_pretty 
-------------------------------+-------------+-------------------------+---------------------+---------------------+-------------+--------------
 2026-02-18 17:36:12.070884-05 | perf        | order_items             |                   0 |                   0 |   122626048 | 117 MB
 2026-02-18 17:36:12.070884-05 | perf        | app_events              |                   0 |                   0 |    99270656 | 95 MB
 2026-02-18 17:36:12.070884-05 | perf        | payments                |                   0 |                   0 |    87080960 | 83 MB
 2026-02-18 17:36:12.070884-05 | perf        | orders                  |                   0 |                   0 |    78512128 | 75 MB
 2026-02-18 17:36:12.070884-05 | perf        | shipments               |                   0 |                   0 |    19038208 | 18 MB
 2026-02-18 17:36:12.070884-05 | perf        | users                   |                   0 |                   0 |     4833280 | 4720 kB
 2026-02-18 17:36:12.070884-05 | public      | demo_users              |                   0 |                   0 |     4505600 | 4400 kB
 2026-02-18 17:36:12.070884-05 | perf        | inventory               |                   0 |                   0 |     3497984 | 3416 kB
 2026-02-18 17:36:12.070884-05 | perf        | product_categories      |                   0 |                   0 |     2703360 | 2640 kB
 2026-02-18 17:36:12.070884-05 | perf        | products                |                   0 |                   0 |     2285568 | 2232 kB
 2026-02-18 17:36:12.070884-05 | perf        | addresses               |                   0 |                   0 |     1613824 | 1576 kB
 2026-02-18 17:36:12.070884-05 | perf        | sessions                |                   0 |                   0 |     1376256 | 1344 kB
 2026-02-18 17:36:12.070884-05 | perf        | feature_flags           |                   0 |                   0 |      122880 | 120 kB
 2026-02-18 17:36:12.070884-05 | perf        | categories              |                   0 |                   0 |       98304 | 96 kB
 2026-02-18 17:36:12.070884-05 | dba_metrics | index_size_snapshots    |                 102 |                   0 |       49152 | 48 kB
 2026-02-18 17:36:12.070884-05 | perf        | tenants                 |                   0 |                   0 |       32768 | 32 kB
 2026-02-18 17:36:12.070884-05 | perf        | audit_log               |                   0 |                   0 |       24576 | 24 kB
 2026-02-18 17:36:12.070884-05 | perf        | documents               |                   0 |                   0 |       24576 | 24 kB
```

### 02_table_storage/04_relation_storage_parameters.sql
- Status: PASS
- Exit code: 0
- Output file: out/02_table_storage/04_relation_storage_parameters.out.txt

```text
 schema_name |       table_name        | relation_options 
-------------+-------------------------+------------------
 dba_metrics | connection_snapshots    | 
 dba_metrics | database_size_snapshots | 
 dba_metrics | index_size_snapshots    | 
 dba_metrics | table_size_snapshots    | 
 dba_metrics | wal_snapshots           | 
 perf        | addresses               | 
 perf        | app_events              | 
 perf        | audit_log               | 
 perf        | categories              | 
 perf        | documents               | 
 perf        | feature_flags           | 
 perf        | inventory               | 
 perf        | job_runs                | 
 perf        | jobs                    | 
 perf        | notifications           | 
 perf        | order_items             | 
 perf        | orders                  | 
 perf        | payments                | 
```

### 03_index_analysis/01_index_size_and_usage.sql
- Status: PASS
- Exit code: 0
- Output file: out/03_index_analysis/01_index_size_and_usage.out.txt

```text
 schema_name |     table_name     |                  index_name                  | index_bytes | index_pretty | idx_scan | idx_tup_read | idx_tup_fetch 
-------------+--------------------+----------------------------------------------+-------------+--------------+----------+--------------+---------------
 perf        | payments           | payments_tenant_id_order_id_payment_ts_idx   |    66355200 | 63 MB        |        0 |            0 |             0
 perf        | order_items        | order_items_pkey                             |    63356928 | 60 MB        |        0 |            0 |             0
 perf        | order_items        | order_items_tenant_id_order_id_idx           |    59195392 | 56 MB        |        0 |            0 |             0
 perf        | app_events         | app_events_pkey                              |    56172544 | 54 MB        |        0 |            0 |             0
 perf        | orders             | orders_tenant_id_user_id_order_ts_idx        |    47792128 | 46 MB        |        0 |            0 |             0
 perf        | app_events         | app_events_tenant_id_event_type_event_ts_idx |    22667264 | 22 MB        |        0 |            0 |             0
 perf        | orders             | orders_pkey                                  |    21135360 | 20 MB        |        0 |            0 |             0
 perf        | payments           | payments_pkey                                |    20709376 | 20 MB        |        0 |            0 |             0
 perf        | app_events         | app_events_tenant_id_event_ts_idx            |    20406272 | 19 MB        |        0 |            0 |             0
 perf        | shipments          | shipments_pkey                               |    19013632 | 18 MB        |        0 |            0 |             0
 perf        | orders             | orders_tenant_id_order_ts_idx                |     9568256 | 9344 kB      |        0 |            0 |             0
 perf        | inventory          | inventory_pkey                               |     3481600 | 3400 kB      |        0 |            0 |             0
 perf        | product_categories | product_categories_pkey                      |     2686976 | 2624 kB      |        0 |            0 |             0
 perf        | users              | users_tenant_id_status_created_at_idx        |     2547712 | 2488 kB      |        0 |            0 |             0
 perf        | users              | users_pkey                                   |     2260992 | 2208 kB      |        0 |            0 |             0
 perf        | products           | products_pkey                                |     2260992 | 2208 kB      |        0 |            0 |             0
 perf        | addresses          | addresses_pkey                               |     1589248 | 1552 kB      |        0 |            0 |             0
 perf        | sessions           | sessions_pkey                                |     1359872 | 1328 kB      |        0 |            0 |             0
```

### 03_index_analysis/02_unused_indexes_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/03_index_analysis/02_unused_indexes_candidates.out.txt

```text
 schema_name | table_name  |                  index_name                  | index_bytes | index_pretty | idx_scan 
-------------+-------------+----------------------------------------------+-------------+--------------+----------
 perf        | payments    | payments_tenant_id_order_id_payment_ts_idx   |    66355200 | 63 MB        |        0
 perf        | order_items | order_items_tenant_id_order_id_idx           |    59195392 | 56 MB        |        0
 perf        | orders      | orders_tenant_id_user_id_order_ts_idx        |    47792128 | 46 MB        |        0
 perf        | app_events  | app_events_tenant_id_event_type_event_ts_idx |    22667264 | 22 MB        |        0
 perf        | app_events  | app_events_tenant_id_event_ts_idx            |    20406272 | 19 MB        |        0
 perf        | orders      | orders_tenant_id_order_ts_idx                |     9568256 | 9344 kB      |        0
 perf        | users       | users_tenant_id_status_created_at_idx        |     2547712 | 2488 kB      |        0
 public      | demo_users  | idx_demo_users_username                      |      368640 | 360 kB       |        0
 public      | demo_users  | demo_users_username_idx                      |      368640 | 360 kB       |        0
 public      | demo_users  | demo_users_username_idx1                     |      368640 | 360 kB       |        0
 perf        | documents   | documents_tenant_id_created_at_idx           |        8192 | 8192 bytes   |        0
 perf        | audit_log   | audit_log_tenant_id_audit_ts_idx             |        8192 | 8192 bytes   |        0
(12 rows)

```

### 03_index_analysis/03_duplicate_indexes.sql
- Status: PASS
- Exit code: 0
- Output file: out/03_index_analysis/03_duplicate_indexes.out.txt

```text
 schema_name | table_name |                             duplicate_indexes                              | total_duplicate_bytes | total_duplicate_pretty 
-------------+------------+----------------------------------------------------------------------------+-----------------------+------------------------
 public      | demo_users | {demo_users_username_idx,demo_users_username_idx1,idx_demo_users_username} |               1105920 | 1080 kB
(1 row)

```

### 03_index_analysis/04_index_maintenance_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/03_index_analysis/04_index_maintenance_candidates.out.txt

```text
 schema_name |     table_name     |                  index_name                  | index_bytes | index_pretty | idx_scan | recommendation 
-------------+--------------------+----------------------------------------------+-------------+--------------+----------+----------------
 perf        | payments           | payments_tenant_id_order_id_payment_ts_idx   |    66355200 | 63 MB        |        0 | Observe
 perf        | order_items        | order_items_pkey                             |    63356928 | 60 MB        |        0 | Observe
 perf        | order_items        | order_items_tenant_id_order_id_idx           |    59195392 | 56 MB        |        0 | Observe
 perf        | app_events         | app_events_pkey                              |    56172544 | 54 MB        |        0 | Observe
 perf        | orders             | orders_tenant_id_user_id_order_ts_idx        |    47792128 | 46 MB        |        0 | Observe
 perf        | app_events         | app_events_tenant_id_event_type_event_ts_idx |    22667264 | 22 MB        |        0 | Observe
 perf        | orders             | orders_pkey                                  |    21135360 | 20 MB        |        0 | Observe
 perf        | payments           | payments_pkey                                |    20709376 | 20 MB        |        0 | Observe
 perf        | app_events         | app_events_tenant_id_event_ts_idx            |    20406272 | 19 MB        |        0 | Observe
 perf        | shipments          | shipments_pkey                               |    19013632 | 18 MB        |        0 | Observe
 perf        | orders             | orders_tenant_id_order_ts_idx                |     9568256 | 9344 kB      |        0 | Observe
 perf        | inventory          | inventory_pkey                               |     3481600 | 3400 kB      |        0 | Observe
 perf        | product_categories | product_categories_pkey                      |     2686976 | 2624 kB      |        0 | Observe
 perf        | users              | users_tenant_id_status_created_at_idx        |     2547712 | 2488 kB      |        0 | Observe
 perf        | users              | users_pkey                                   |     2260992 | 2208 kB      |        0 | Observe
 perf        | products           | products_pkey                                |     2260992 | 2208 kB      |        0 | Observe
 perf        | addresses          | addresses_pkey                               |     1589248 | 1552 kB      |        0 | Observe
 perf        | sessions           | sessions_pkey                                |     1359872 | 1328 kB      |        0 | Observe
```

### 04_toast_lob_blob/01_tables_with_toast.sql
- Status: PASS
- Exit code: 0
- Output file: out/04_toast_lob_blob/01_tables_with_toast.out.txt

```text
 schema_name |       table_name        | toast_table_name | toast_total_bytes | toast_total_pretty 
-------------+-------------------------+------------------+-------------------+--------------------
 perf        | tenants                 | pg_toast_16391   |              8192 | 8192 bytes
 perf        | users                   | pg_toast_16404   |              8192 | 8192 bytes
 perf        | products                | pg_toast_16424   |              8192 | 8192 bytes
 perf        | categories              | pg_toast_16444   |              8192 | 8192 bytes
 perf        | shipments               | pg_toast_16544   |              8192 | 8192 bytes
 perf        | app_events              | pg_toast_16562   |              8192 | 8192 bytes
 perf        | audit_log               | pg_toast_16576   |              8192 | 8192 bytes
 perf        | documents               | pg_toast_16590   |              8192 | 8192 bytes
 perf        | addresses               | pg_toast_16604   |              8192 | 8192 bytes
 perf        | feature_flags           | pg_toast_16640   |              8192 | 8192 bytes
 perf        | support_tickets         | pg_toast_16665   |              8192 | 8192 bytes
 perf        | ticket_comments         | pg_toast_16685   |              8192 | 8192 bytes
 perf        | notifications           | pg_toast_16704   |              8192 | 8192 bytes
 perf        | jobs                    | pg_toast_16724   |              8192 | 8192 bytes
 perf        | job_runs                | pg_toast_16738   |              8192 | 8192 bytes
 dba_metrics | table_size_snapshots    | pg_toast_25389   |              8192 | 8192 bytes
 public      | demo_users              | pg_toast_16841   |              8192 | 8192 bytes
 dba_metrics | index_size_snapshots    | pg_toast_25399   |              8192 | 8192 bytes
```

### 04_toast_lob_blob/02_toast_heavy_tables.sql
- Status: PASS
- Exit code: 0
- Output file: out/04_toast_lob_blob/02_toast_heavy_tables.out.txt

```text
 schema_name |       table_name        | table_total_bytes | table_total_pretty | toast_bytes | toast_pretty | toast_pct 
-------------+-------------------------+-------------------+--------------------+-------------+--------------+-----------
 perf        | support_tickets         |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 dba_metrics | wal_snapshots           |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 dba_metrics | database_size_snapshots |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 dba_metrics | connection_snapshots    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 dba_metrics | table_size_snapshots    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 perf        | job_runs                |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 perf        | jobs                    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 perf        | notifications           |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 perf        | ticket_comments         |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
 perf        | audit_log               |             24576 | 24 kB              |        8192 | 8192 bytes   |     33.33
 perf        | documents               |             24576 | 24 kB              |        8192 | 8192 bytes   |     33.33
 perf        | tenants                 |             32768 | 32 kB              |        8192 | 8192 bytes   |     25.00
 dba_metrics | index_size_snapshots    |             49152 | 48 kB              |        8192 | 8192 bytes   |     16.67
 perf        | categories              |             98304 | 96 kB              |        8192 | 8192 bytes   |      8.33
 perf        | feature_flags           |            122880 | 120 kB             |        8192 | 8192 bytes   |      6.67
 perf        | addresses               |           1613824 | 1576 kB            |        8192 | 8192 bytes   |      0.51
 perf        | products                |           2285568 | 2232 kB            |        8192 | 8192 bytes   |      0.36
 public      | demo_users              |           4505600 | 4400 kB            |        8192 | 8192 bytes   |      0.18
```

### 04_toast_lob_blob/03_large_objects_summary.sql
- Status: PASS
- Exit code: 0
- Output file: out/04_toast_lob_blob/03_large_objects_summary.out.txt

```text
 large_object_count | total_bytes | total_pretty 
--------------------+-------------+--------------
                  0 |           0 | 0 bytes
(1 row)

```

### 04_toast_lob_blob/04_top_large_objects.sql
- Status: PASS
- Exit code: 0
- Output file: out/04_toast_lob_blob/04_top_large_objects.out.txt

```text
 loid | large_object_bytes | large_object_pretty | chunk_count 
------+--------------------+---------------------+-------------
(0 rows)

```

### 05_partitioning/01_partitioned_tables_overview.sql
- Status: PASS
- Exit code: 0
- Output file: out/05_partitioning/01_partitioned_tables_overview.out.txt

```text
 parent_schema | partitioned_table | partition_key | partition_count 
---------------+-------------------+---------------+-----------------
(0 rows)

```

### 05_partitioning/02_partition_size_distribution.sql
- Status: PASS
- Exit code: 0
- Output file: out/05_partitioning/02_partition_size_distribution.out.txt

```text
 parent_schema | parent_table | partition_schema | partition_name | partition_bytes | partition_pretty 
---------------+--------------+------------------+----------------+-----------------+------------------
(0 rows)

```

### 05_partitioning/03_partitions_without_indexes.sql
- Status: PASS
- Exit code: 0
- Output file: out/05_partitioning/03_partitions_without_indexes.out.txt

```text
 parent_schema | parent_table | partition_schema | partition_name | index_count 
---------------+--------------+------------------+----------------+-------------
(0 rows)

```

### 05_partitioning/04_partitioning_recommendation_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/05_partitioning/04_partitioning_recommendation_candidates.out.txt

```text
 schema_name |       table_name        | total_bytes | total_pretty | estimated_live_rows | write_volume | recommendation 
-------------+-------------------------+-------------+--------------+---------------------+--------------+----------------
 perf        | order_items             |   122626048 | 117 MB       |                   0 |            0 | Low priority
 perf        | app_events              |    99270656 | 95 MB        |                   0 |            0 | Low priority
 perf        | payments                |    87080960 | 83 MB        |                   0 |            0 | Low priority
 perf        | orders                  |    78512128 | 75 MB        |                   0 |            0 | Low priority
 perf        | shipments               |    19038208 | 18 MB        |                   0 |            0 | Low priority
 perf        | users                   |     4833280 | 4720 kB      |                   0 |            0 | Low priority
 public      | demo_users              |     4505600 | 4400 kB      |                   0 |            0 | Low priority
 perf        | inventory               |     3497984 | 3416 kB      |                   0 |            0 | Low priority
 perf        | product_categories      |     2703360 | 2640 kB      |                   0 |            0 | Low priority
 perf        | products                |     2285568 | 2232 kB      |                   0 |            0 | Low priority
 perf        | addresses               |     1613824 | 1576 kB      |                   0 |            0 | Low priority
 perf        | sessions                |     1376256 | 1344 kB      |                   0 |            0 | Low priority
 perf        | feature_flags           |      122880 | 120 kB       |                   0 |            0 | Low priority
 perf        | categories              |       98304 | 96 kB        |                   0 |            0 | Low priority
 dba_metrics | index_size_snapshots    |       49152 | 48 kB        |                 102 |          102 | Low priority
 perf        | tenants                 |       32768 | 32 kB        |                   0 |            0 | Low priority
 perf        | audit_log               |       24576 | 24 kB        |                   0 |            0 | Low priority
 perf        | documents               |       24576 | 24 kB        |                   0 |            0 | Low priority
```

### 06_activity_locks/01_active_sessions.sql
- Status: PASS
- Exit code: 0
- Output file: out/06_activity_locks/01_active_sessions.out.txt

```text
  pid  | user_name | application_name | client_addr |         backend_start         | xact_start |          query_start          |    query_age    | state | wait_event_type |     wait_event      |                                                                                                                                                                                                  query_snippet                                                                                                                                                                                                   
-------+-----------+------------------+-------------+-------------------------------+------------+-------------------------------+-----------------+-------+-----------------+---------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 80570 | saiendla  | psql             |             | 2026-02-18 16:44:04.549466-05 |            | 2026-02-18 16:44:24.420894-05 | 00:51:47.948691 | idle  | Client          | ClientRead          | SELECT                                                                                                                                                                                                                                                                                                                                                                                                          +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     current_database() AS database_name,                                                                                                                                                                                                                                                                                                                                                                        +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     current_user AS login_role,                                                                                                                                                                                                                                                                                                                                                                                 +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     version() AS server_version,                                                                                                                                                                                                                                                                                                                                                                                +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     current_setting('server_version_num') AS server_version_num,                                                                                                                                                                                                                                                                                                                                                +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     pg_postmaster_start_time() AS postmaster_start_time,                                                                                                                                                                                                                                                                                                                                                        +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     now() - pg_postmaster_start_time() AS instance_uptime,                                                                                                                                                                                                                                                                                                                                                      +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     current_setting('data_directory') AS data_directory,                                                                                                                                                                                                                                                                                                                                                        +
       |           |                  |             |                               |            |                               |                 |       |                 |                     |     current_setting('config_file') AS config_file
 98359 | saiendla  | dbvis            | 127.0.0.1   | 2026-02-18 17:30:39.557297-05 |            | 2026-02-18 17:30:39.626331-05 | 00:05:32.743254 | idle  | Client          | ClientRead          | SELECT c.oid, a.attnum, a.attname, c.relname, n.nspname, a.attnotnull OR (t.typtype = 'd' AND t.typnotnull), a.attidentity != '' OR pg_catalog.pg_get_expr(d.adbin, d.adrelid) LIKE '%nextval(%' FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid) JOIN pg_catalog.pg_attribute a ON (c.oid = a.attrelid) JOIN pg_catalog.pg_type t ON (a.atttypid = t.oid) LEFT JOIN pg_cat
 98321 | saiendla  | dbvis            | 127.0.0.1   | 2026-02-18 17:30:31.175582-05 |            | 2026-02-18 17:30:47.003016-05 | 00:05:25.366569 | idle  | Client          | ClientRead          | SELECT 1
 98412 | saiendla  | dbvis            | 127.0.0.1   | 2026-02-18 17:30:52.332242-05 |            | 2026-02-18 17:30:53.560003-05 | 00:05:18.809582 | idle  | Client          | ClientRead          | show search_path
   886 |           |                  |             | 2026-02-10 09:32:09.200077-05 |            |                               |                 |       | Activity        | IoWorkerMain        | 
   887 |           |                  |             | 2026-02-10 09:32:09.201055-05 |            |                               |                 |       | Activity        | IoWorkerMain        | 
   888 |           |                  |             | 2026-02-10 09:32:09.202493-05 |            |                               |                 |       | Activity        | CheckpointerMain    | 
   889 |           |                  |             | 2026-02-10 09:32:09.20292-05  |            |                               |                 |       | Activity        | BgwriterHibernate   | 
   891 |           |                  |             | 2026-02-10 09:32:09.21264-05  |            |                               |                 |       | Activity        | WalWriterMain       | 
   892 |           |                  |             | 2026-02-10 09:32:09.214793-05 |            |                               |                 |       | Activity        | AutovacuumMain      | 
```

### 06_activity_locks/02_blocking_and_blocked_sessions.sql
- Status: PASS
- Exit code: 0
- Output file: out/06_activity_locks/02_blocking_and_blocked_sessions.out.txt

```text
 blocked_pid | blocked_user | blocked_app | blocked_state | blocked_query_age | blocked_query | blocker_pid | blocker_user | blocker_app | blocker_state | blocker_query_age | blocker_query 
-------------+--------------+-------------+---------------+-------------------+---------------+-------------+--------------+-------------+---------------+-------------------+---------------
(0 rows)

```

### 06_activity_locks/03_long_running_transactions.sql
- Status: PASS
- Exit code: 0
- Output file: out/06_activity_locks/03_long_running_transactions.out.txt

```text
 pid | user_name | application_name | client_addr | xact_start | xact_age | state | wait_event_type | wait_event | query_snippet 
-----+-----------+------------------+-------------+------------+----------+-------+-----------------+------------+---------------
(0 rows)

```

### 06_activity_locks/04_wait_events_summary.sql
- Status: PASS
- Exit code: 0
- Output file: out/06_activity_locks/04_wait_events_summary.out.txt

```text
 wait_event_type |     wait_event      | state  | session_count 
-----------------+---------------------+--------+---------------
 Client          | ClientRead          | idle   |             4
 Activity        | IoWorkerMain        |        |             3
 Activity        | AutovacuumMain      |        |             1
 Activity        | BgwriterHibernate   |        |             1
 Activity        | CheckpointerMain    |        |             1
 Activity        | LogicalLauncherMain |        |             1
 Activity        | WalWriterMain       |        |             1
 CPU/None        | CPU/None            | active |             1
(8 rows)

```

### 07_vacuum_bloat/01_table_bloat_estimate.sql
- Status: PASS
- Exit code: 0
- Output file: out/07_vacuum_bloat/01_table_bloat_estimate.out.txt

```text
 schema_name | table_name | total_bytes | total_pretty | n_live_tup | n_dead_tup | dead_tuple_pct | est_bloat_bytes | est_bloat_pretty 
-------------+------------+-------------+--------------+------------+------------+----------------+-----------------+------------------
(0 rows)

```

### 07_vacuum_bloat/02_autovacuum_table_status.sql
- Status: PASS
- Exit code: 0
- Output file: out/07_vacuum_bloat/02_autovacuum_table_status.out.txt

```text
 schema_name |       table_name        | n_live_tup | n_dead_tup | last_vacuum | last_autovacuum | last_analyze |       last_autoanalyze        | vacuum_count | autovacuum_count | analyze_count | autoanalyze_count 
-------------+-------------------------+------------+------------+-------------+-----------------+--------------+-------------------------------+--------------+------------------+---------------+-------------------
 dba_metrics | index_size_snapshots    |        102 |          0 |             |                 |              | 2026-02-18 17:29:34.45373-05  |            0 |                0 |             0 |                 1
 dba_metrics | table_size_snapshots    |         81 |          0 |             |                 |              | 2026-02-18 17:29:34.451723-05 |            0 |                0 |             0 |                 1
 dba_metrics | database_size_snapshots |         21 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 dba_metrics | connection_snapshots    |         14 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 dba_metrics | wal_snapshots           |          3 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | tenants                 |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | addresses               |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | job_runs                |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | products                |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | sessions                |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | audit_log               |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | documents               |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | users                   |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | order_items             |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | payments                |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | app_events              |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 public      | demo_users              |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
 perf        | inventory               |          0 |          0 |             |                 |              |                               |            0 |                0 |             0 |                 0
```

### 07_vacuum_bloat/03_freeze_age_risk.sql
- Status: PASS
- Exit code: 0
- Output file: out/07_vacuum_bloat/03_freeze_age_risk.out.txt

```text
 schema_name |       table_name        | relfrozenxid_age | toast_relfrozenxid_age | total_size 
-------------+-------------------------+------------------+------------------------+------------
 perf        | tenants                 |          5333090 |                5333090 | 32 kB
 perf        | audit_log               |          5333080 |                5333080 | 24 kB
 perf        | documents               |          5333079 |                5333079 | 24 kB
 perf        | support_tickets         |          5333074 |                5333074 | 16 kB
 perf        | ticket_comments         |          5333073 |                5333073 | 16 kB
 perf        | notifications           |          5333072 |                5333072 | 16 kB
 perf        | jobs                    |          5333071 |                5333071 | 16 kB
 perf        | job_runs                |          5333070 |                5333070 | 16 kB
 perf        | users                   |          5333054 |                5333089 | 4720 kB
 perf        | products                |          5333053 |                5333088 | 2232 kB
 perf        | payments                |          5333052 |                        | 83 MB
 perf        | categories              |          5333051 |                5333087 | 96 kB
 perf        | product_categories      |          5333050 |                        | 2640 kB
 perf        | orders                  |          5333049 |                        | 75 MB
 perf        | order_items             |          5333049 |                        | 117 MB
 perf        | shipments               |          5333048 |                5333082 | 18 MB
 perf        | addresses               |          5333047 |                5333078 | 1576 kB
 perf        | app_events              |          5333047 |                5333081 | 95 MB
```

### 07_vacuum_bloat/04_dead_tuples_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/07_vacuum_bloat/04_dead_tuples_hotspots.out.txt

```text
 schema_name | table_name | n_live_tup | n_dead_tup | dead_tuple_pct | total_size 
-------------+------------+------------+------------+----------------+------------
(0 rows)

```

### 07_vacuum_bloat/05_vacuum_progress.sql
- Status: PASS
- Exit code: 0
- Output file: out/07_vacuum_bloat/05_vacuum_progress.out.txt

```text
 pid | schema_name | table_name | phase | heap_blks_total | heap_blks_scanned | heap_blks_vacuumed | index_vacuum_count | max_dead_tuple_bytes | dead_tuple_bytes | num_dead_item_ids 
-----+-------------+------------+-------+-----------------+-------------------+--------------------+--------------------+----------------------+------------------+-------------------
(0 rows)

```

### 08_replication_ha/01_primary_replication_status.sql
- Status: PASS
- Exit code: 0
- Output file: out/08_replication_ha/01_primary_replication_status.out.txt

```text
 pid | user_name | application_name | client_addr | state | sync_state | sent_lsn | write_lsn | flush_lsn | replay_lsn | byte_lag | write_lag | flush_lag | replay_lag 
-----+-----------+------------------+-------------+-------+------------+----------+-----------+-----------+------------+----------+-----------+-----------+------------
(0 rows)

```

### 08_replication_ha/02_standby_replay_status.sql
- Status: PASS
- Exit code: 0
- Output file: out/08_replication_ha/02_standby_replay_status.out.txt

```text
 is_standby | last_received_lsn | last_replayed_lsn | last_replay_timestamp | replay_delay 
------------+-------------------+-------------------+-----------------------+--------------
 f          |                   |                   |                       | 
(1 row)

```

### 08_replication_ha/03_replication_slots_health.sql
- Status: PASS
- Exit code: 0
- Output file: out/08_replication_ha/03_replication_slots_health.out.txt

```text
 slot_name | slot_type | active | temporary | restart_lsn | confirmed_flush_lsn | retained_wal_bytes | retained_wal_pretty | wal_status | safe_wal_size 
-----------+-----------+--------+-----------+-------------+---------------------+--------------------+---------------------+------------+---------------
(0 rows)

```

### 08_replication_ha/04_wal_generation_rate.sql
- Status: PASS
- Exit code: 0
- Output file: out/08_replication_ha/04_wal_generation_rate.out.txt

```text
 wal_records | wal_fpi |  wal_bytes  |          stats_reset          | elapsed_seconds | wal_bytes_per_second | wal_rate_pretty_per_second 
-------------+---------+-------------+-------------------------------+-----------------+----------------------+----------------------------
    44801199 |  672201 | 31496511778 | 2026-01-31 20:40:48.109778-05 |         1544125 |             20397.65 | 20 kB
(1 row)

```

### 09_security_roles/01_roles_and_membership.sql
- Status: PASS
- Exit code: 0
- Output file: out/09_security_roles/01_roles_and_membership.out.txt

```text
          role_name          | can_login | is_superuser | can_create_db | can_create_role |    member_of_role    
-----------------------------+-----------+--------------+---------------+-----------------+----------------------
 pg_checkpoint               | f         | f            | f             | f               | 
 pg_create_subscription      | f         | f            | f             | f               | 
 pg_database_owner           | f         | f            | f             | f               | 
 pg_execute_server_program   | f         | f            | f             | f               | 
 pg_maintain                 | f         | f            | f             | f               | 
 pg_monitor                  | f         | f            | f             | f               | pg_read_all_settings
 pg_monitor                  | f         | f            | f             | f               | pg_read_all_stats
 pg_monitor                  | f         | f            | f             | f               | pg_stat_scan_tables
 pg_read_all_data            | f         | f            | f             | f               | 
 pg_read_all_settings        | f         | f            | f             | f               | 
 pg_read_all_stats           | f         | f            | f             | f               | 
 pg_read_server_files        | f         | f            | f             | f               | 
 pg_signal_autovacuum_worker | f         | f            | f             | f               | 
 pg_signal_backend           | f         | f            | f             | f               | 
 pg_stat_scan_tables         | f         | f            | f             | f               | 
 pg_use_reserved_connections | f         | f            | f             | f               | 
 pg_write_all_data           | f         | f            | f             | f               | 
 pg_write_server_files       | f         | f            | f             | f               | 
```

### 09_security_roles/02_high_privilege_roles.sql
- Status: PASS
- Exit code: 0
- Output file: out/09_security_roles/02_high_privilege_roles.out.txt

```text
 role_name | is_superuser | can_replicate | bypasses_row_level_security | can_create_roles | can_create_databases | can_login 
-----------+--------------+---------------+-----------------------------+------------------+----------------------+-----------
 postgres  | t            | t             | f                           | t                | t                    | t
 saiendla  | t            | t             | t                           | t                | t                    | t
(2 rows)

```

### 09_security_roles/03_table_grants_by_role.sql
- Status: PASS
- Exit code: 0
- Output file: out/09_security_roles/03_table_grants_by_role.out.txt

```text
 table_schema |       table_name        | grantee  | privilege_type | is_grantable 
--------------+-------------------------+----------+----------------+--------------
 dba_metrics  | connection_snapshots    | saiendla | DELETE         | YES
 dba_metrics  | connection_snapshots    | saiendla | INSERT         | YES
 dba_metrics  | connection_snapshots    | saiendla | REFERENCES     | YES
 dba_metrics  | connection_snapshots    | saiendla | SELECT         | YES
 dba_metrics  | connection_snapshots    | saiendla | TRIGGER        | YES
 dba_metrics  | connection_snapshots    | saiendla | TRUNCATE       | YES
 dba_metrics  | connection_snapshots    | saiendla | UPDATE         | YES
 dba_metrics  | database_size_snapshots | saiendla | DELETE         | YES
 dba_metrics  | database_size_snapshots | saiendla | INSERT         | YES
 dba_metrics  | database_size_snapshots | saiendla | REFERENCES     | YES
 dba_metrics  | database_size_snapshots | saiendla | SELECT         | YES
 dba_metrics  | database_size_snapshots | saiendla | TRIGGER        | YES
 dba_metrics  | database_size_snapshots | saiendla | TRUNCATE       | YES
 dba_metrics  | database_size_snapshots | saiendla | UPDATE         | YES
 dba_metrics  | index_size_snapshots    | saiendla | DELETE         | YES
 dba_metrics  | index_size_snapshots    | saiendla | INSERT         | YES
 dba_metrics  | index_size_snapshots    | saiendla | REFERENCES     | YES
 dba_metrics  | index_size_snapshots    | saiendla | SELECT         | YES
```

### 09_security_roles/04_default_privileges.sql
- Status: PASS
- Exit code: 0
- Output file: out/09_security_roles/04_default_privileges.out.txt

```text
 schema_name | owner_role | object_type | default_acl 
-------------+------------+-------------+-------------
(0 rows)

```

### 10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql
- Status: PASS
- Exit code: 0
- Output file: out/10_maintenance_monitoring/01_bgwriter_checkpoint_stats.out.txt

```text
 checkpoints_timed | checkpoints_req | checkpoint_write_time | checkpoint_sync_time | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_alloc |   checkpointer_stats_reset    |     bgwriter_stats_reset      
-------------------+-----------------+-----------------------+----------------------+--------------------+--------------+---------------+------------------+---------------+-------------------------------+-------------------------------
               826 |              59 |               2788826 |                48655 |              27276 |          210 |        244345 |             2422 |      10825264 | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
(1 row)

```

### 10_maintenance_monitoring/02_cache_hit_ratio.sql
- Status: PASS
- Exit code: 0
- Output file: out/10_maintenance_monitoring/02_cache_hit_ratio.out.txt

```text
 table_cache_hit_pct | index_cache_hit_pct 
---------------------+---------------------
              100.00 |                    
(1 row)

```

### 10_maintenance_monitoring/03_top_statements_pg_stat_statements.sql
- Status: PASS
- Exit code: 0
- Output file: out/10_maintenance_monitoring/03_top_statements_pg_stat_statements.out.txt

```text
       queryid        |  calls  |  total_exec_time   |     mean_exec_time     |  rows   | shared_blks_hit | shared_blks_read | temp_blks_written |                                                                                                                                                                                                                                                    query_snippet                                                                                                                                                                                                                                                     
----------------------+---------+--------------------+------------------------+---------+-----------------+------------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 | 20318063.253471453 |     3.8100014295381928 | 5332823 |        45639018 |         10664795 |                 0 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |  440938.2827256841 |    0.08268383982104996 | 5332823 |        30081894 |             1205 |                 0 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 | 209356.47065673055 |   0.039258094757131864 | 5332823 |        27087536 |             1533 |                 0 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 | 107882.85510483896 |   0.020229971087544072 | 5332823 |         5534382 |            19313 |                 0 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |  36480.01148695377 |   0.006840656719152106 | 5332823 |        29324806 |               55 |                 0 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |  20055.74470699987 |     2.8211766362357635 |   35545 |          216589 |               97 |                 0 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                                                                                                                                                                                    +
                      |         |                    |                        |         |                 |                  |                   | FROM (SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                                                                                                                                                                                                                                                       +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",                                                                                                                                                                                                                                                                                                                                                      +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_da
   450201137788272562 |       1 |        1674.504167 |            1674.504167 |       0 |            9664 |            29989 |                 0 | ANALYZE
 -5398677000037045473 |       1 |         802.498625 |             802.498625 |       0 |             238 |            53105 |                 0 | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
  6097083398544187049 | 5332823 |  610.4023310318215 | 0.00011446138958671586 |       0 |               0 |                0 |                 0 | END
  4854991825702068830 | 5332823 |   599.397160031148 | 0.00011239772255708013 |       0 |               0 |                0 |                 0 | BEGIN
  4640742184386830055 |      63 |         155.489831 |     2.4680925555555544 |      63 |             559 |                8 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  4640742184386830055 |      64 | 114.79591899999996 |     1.7936862343750006 |      64 |             576 |                0 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  8710856124765966157 |       3 |         105.637749 |              35.212583 |    1011 |           12633 |               48 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              +
                      |         |                    |                        |         |                 |                  |                   |     n.nspname AS schema_name,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       +
```

### 10_maintenance_monitoring/04_non_default_config.sql
- Status: PASS
- Exit code: 0
- Output file: out/10_maintenance_monitoring/04_non_default_config.out.txt

```text
               name                |                     setting                     | unit |       source       |     boot_val      |                    reset_val                    
-----------------------------------+-------------------------------------------------+------+--------------------+-------------------+-------------------------------------------------
 application_name                  | psql                                            |      | client             |                   | psql
 autovacuum_worker_slots           | 16                                              |      | configuration file | 16                | 16
 config_file                       | /opt/homebrew/var/postgresql@18/postgresql.conf |      | override           |                   | /opt/homebrew/var/postgresql@18/postgresql.conf
 data_directory                    | /opt/homebrew/var/postgresql@18                 |      | override           |                   | /opt/homebrew/var/postgresql@18
 DateStyle                         | ISO, MDY                                        |      | configuration file | ISO, MDY          | ISO, MDY
 default_text_search_config        | pg_catalog.english                              |      | configuration file | pg_catalog.simple | pg_catalog.english
 dynamic_shared_memory_type        | posix                                           |      | configuration file | posix             | posix
 full_page_writes                  | off                                             |      | configuration file | on                | off
 hba_file                          | /opt/homebrew/var/postgresql@18/pg_hba.conf     |      | override           |                   | /opt/homebrew/var/postgresql@18/pg_hba.conf
 ident_file                        | /opt/homebrew/var/postgresql@18/pg_ident.conf   |      | override           |                   | /opt/homebrew/var/postgresql@18/pg_ident.conf
 lc_messages                       | en_US.UTF-8                                     |      | configuration file |                   | en_US.UTF-8
 lc_monetary                       | en_US.UTF-8                                     |      | configuration file | C                 | en_US.UTF-8
 lc_numeric                        | en_US.UTF-8                                     |      | configuration file | C                 | en_US.UTF-8
 lc_time                           | en_US.UTF-8                                     |      | configuration file | C                 | en_US.UTF-8
 log_timezone                      | America/New_York                                |      | configuration file | GMT               | America/New_York
 max_connections                   | 100                                             |      | configuration file | 100               | 100
 max_wal_size                      | 1024                                            | MB   | configuration file | 1024              | 1024
 min_wal_size                      | 80                                              | MB   | configuration file | 80                | 80
```

### 10_maintenance_monitoring/05_connection_capacity.sql
- Status: PASS
- Exit code: 0
- Output file: out/10_maintenance_monitoring/05_connection_capacity.out.txt

```text
 max_connections | total_connections | active_connections | idle_connections | idle_in_txn_connections | pct_used 
-----------------+-------------------+--------------------+------------------+-------------------------+----------
             100 |                13 |                  1 |                4 |                       0 |    13.00
(1 row)

```

### 11_performance_tuning/01_top_queries_by_total_exec_time.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/01_top_queries_by_total_exec_time.out.txt

```text
       queryid        |  calls  |  total_exec_time   |     mean_exec_time     |  rows   | shared_blks_hit | shared_blks_read | temp_blks_written |                                                                                                                                                                                                                                                    query_snippet                                                                                                                                                                                                                                                     
----------------------+---------+--------------------+------------------------+---------+-----------------+------------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 | 20318063.253471453 |     3.8100014295381928 | 5332823 |        45639018 |         10664795 |                 0 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |  440938.2827256841 |    0.08268383982104996 | 5332823 |        30081894 |             1205 |                 0 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 | 209356.47065673055 |   0.039258094757131864 | 5332823 |        27087536 |             1533 |                 0 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 | 107882.85510483896 |   0.020229971087544072 | 5332823 |         5534382 |            19313 |                 0 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |  36480.01148695377 |   0.006840656719152106 | 5332823 |        29324806 |               55 |                 0 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |  20055.74470699987 |     2.8211766362357635 |   35545 |          216589 |               97 |                 0 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                                                                                                                                                                                    +
                      |         |                    |                        |         |                 |                  |                   | FROM (SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                                                                                                                                                                                                                                                       +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",                                                                                                                                                                                                                                                                                                                                                      +
                      |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_da
   450201137788272562 |       1 |        1674.504167 |            1674.504167 |       0 |            9664 |            29989 |                 0 | ANALYZE
 -5398677000037045473 |       1 |         802.498625 |             802.498625 |       0 |             238 |            53105 |                 0 | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
  6097083398544187049 | 5332823 |  610.4023310318215 | 0.00011446138958671586 |       0 |               0 |                0 |                 0 | END
  4854991825702068830 | 5332823 |   599.397160031148 | 0.00011239772255708013 |       0 |               0 |                0 |                 0 | BEGIN
  4640742184386830055 |      63 |         155.489831 |     2.4680925555555544 |      63 |             559 |                8 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  4640742184386830055 |      64 | 114.79591899999996 |     1.7936862343750006 |      64 |             576 |                0 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  8710856124765966157 |       3 |         105.637749 |              35.212583 |    1011 |           12633 |               48 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              +
                      |         |                    |                        |         |                 |                  |                   |     n.nspname AS schema_name,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       +
```

### 11_performance_tuning/02_top_queries_by_mean_exec_time.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/02_top_queries_by_mean_exec_time.out.txt

```text
       queryid        |  calls  |   total_exec_time   |     mean_exec_time     |     min_exec_time     |    max_exec_time    |   stddev_exec_time    |  rows   |                                                                         query_snippet                                                                          
----------------------+---------+---------------------+------------------------+-----------------------+---------------------+-----------------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |  20318063.253471453 |     3.8100014295381928 |  0.005416000000000001 |         8598.566083 |     92.32002420399405 | 5332823 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
  3481893718825960883 |    7109 |   20055.74470699987 |     2.8211766362357635 |              0.191207 |         8578.898084 |    117.82179113781538 |   35545 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                              +
                      |         |                     |                        |                       |                     |                       |         | FROM (SELECT                                                                                                                                                  +
                      |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                 +
                      |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",+
                      |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_da
  4640742184386830055 |      63 |          155.489831 |     2.4680925555555544 |              1.108875 |            9.759916 |    1.0937281720904906 |      63 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  4640742184386830055 |      64 |  114.79591899999996 |     1.7936862343750006 |              1.019208 |            2.651126 |    0.5239858325949681 |      64 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
 -4159615726391246039 |      63 |           10.248413 |    0.16267322222222222 |              0.076375 | 0.24416800000000002 |   0.04069454089219839 |      63 | SELECT                                                                                                                                                        +
                      |         |                     |                        |                       |                     |                       |         |              gss_authenticated, encrypted                                                                                                                     +
                      |         |                     |                        |                       |                     |                       |         |         FROM                                                                                                                                                  +
                      |         |                     |                        |                       |                     |                       |         |             pg_catalog.pg_stat_gssapi                                                                                                                         +
                      |         |                     |                        |                       |                     |                       |         |         WHERE pid = pg_backend_pid()
 -4159615726391246039 |      64 |   7.784874999999997 |    0.12163867187499999 |              0.079583 |            0.218584 |   0.02868252611731504 |      64 | SELECT                                                                                                                                                        +
                      |         |                     |                        |                       |                     |                       |         |              gss_authenticated, encrypted                                                                                                                     +
                      |         |                     |                        |                       |                     |                       |         |         FROM                                                                                                                                                  +
                      |         |                     |                        |                       |                     |                       |         |             pg_catalog.pg_stat_gssapi                                                                                                                         +
                      |         |                     |                        |                       |                     |                       |         |         WHERE pid = pg_backend_pid()
```

### 11_performance_tuning/03_temp_file_heavy_queries.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/03_temp_file_heavy_queries.out.txt

```text
 queryid | calls | temp_blks_read | temp_blks_written | temp_bytes_written | temp_written_pretty | mean_exec_time | query_snippet 
---------+-------+----------------+-------------------+--------------------+---------------------+----------------+---------------
(0 rows)

```

### 11_performance_tuning/04_io_bound_query_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/04_io_bound_query_candidates.out.txt

```text
       queryid        |  calls  |   total_exec_time   |     mean_exec_time     | shared_blks_read | shared_blks_hit | shared_read_pct | temp_blks_written |                                                                                                                                                                                                                                          query_snippet                                                                                                                                                                                                                                          
----------------------+---------+---------------------+------------------------+------------------+-----------------+-----------------+-------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |  20318063.253471453 |     3.8100014295381928 |         10664795 |        45639018 |           18.94 |                 0 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
  4640742184386830055 |      63 |          155.489831 |     2.4680925555555544 |                8 |             559 |            1.41 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  3387776431457662738 | 5332823 |  107882.85510483896 |   0.020229971087544072 |            19313 |         5534382 |            0.35 |                 0 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -6043488156747258108 |      63 |            1.806081 |    0.02866795238095238 |               13 |            3704 |            0.35 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         +
                      |         |                     |                        |                  |                 |                 |                   |     db.oid as did, db.datname, db.datallowconn,                                                                                                                                                                                                                                                                                                                                                                                                                                                +
                      |         |                     |                        |                  |                 |                 |                   |     pg_encoding_to_char(db.encoding) AS serverencoding,                                                                                                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                     |                        |                  |                 |                 |                   |     has_database_privilege(db.oid, $1) as cancreate,                                                                                                                                                                                                                                                                                                                                                                                                                                           +
                      |         |                     |                        |                  |                 |                 |                   |     datistemplate                                                                                                                                                                                                                                                                                                                                                                                                                                                                              +
                      |         |                     |                        |                  |                 |                 |                   | FROM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           +
                      |         |                     |                        |                  |                 |                 |                   |     pg_catalog.pg_database db                                                                                                                                                                                                                                                                                                                                                                                                                                                                  +
                      |         |                     |                        |                  |                 |                 |                   | WHERE db.datname = current_database()
  5052781666619390961 |      63 |   6.369126000000001 |    0.10109723809523813 |               22 |           14153 |            0.16 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         +
                      |         |                     |                        |                  |                 |                 |                   |             roles.oid as id, roles.rolname as name,                                                                                                                                                                                                                                                                                                                                                                                                                                            +
                      |         |                     |                        |                  |                 |                 |                   |             roles.rolsuper as is_superuser,                                                                                                                                                                                                                                                                                                                                                                                                                                                    +
                      |         |                     |                        |                  |                 |                 |                   |             CASE WHEN roles.rolsuper THEN $1 ELSE roles.rolcreaterole END as                                                                                                                                                                                                                                                                                                                                                                                                                   +
                      |         |                     |                        |                  |                 |                 |                   |             can_create_role,                                                                                                                                                                                                                                                                                                                                                                                                                                                                   +
                      |         |                     |                        |                  |                 |                 |                   |             CASE WHEN roles.rolsuper THEN $2                                                                                                                                                                                                                                                                                                                                                                                                                                                   +
                      |         |                     |                        |                  |                 |                 |                   |             ELSE roles.rolcreatedb END as can_create_db,                                                                                                                                                                                                                                                                                                                                                                                                                                       +
```

### 11_performance_tuning/05_performance_related_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/05_performance_related_settings.out.txt

```text
              name               | setting | unit |       source       | boot_val | reset_val 
---------------------------------+---------+------+--------------------+----------+-----------
 cpu_index_tuple_cost            | 0.005   |      | default            | 0.005    | 0.005
 cpu_operator_cost               | 0.0025  |      | default            | 0.0025   | 0.0025
 cpu_tuple_cost                  | 0.01    |      | default            | 0.01     | 0.01
 default_statistics_target       | 100     |      | default            | 100      | 100
 effective_cache_size            | 524288  | 8kB  | default            | 524288   | 524288
 effective_io_concurrency        | 16      |      | default            | 16       | 16
 jit                             | on      |      | default            | on       | on
 jit_above_cost                  | 100000  |      | default            | 100000   | 100000
 maintenance_work_mem            | 65536   | kB   | default            | 65536    | 65536
 max_connections                 | 100     |      | configuration file | 100      | 100
 max_parallel_workers            | 8       |      | default            | 8        | 8
 max_parallel_workers_per_gather | 2       |      | default            | 2        | 2
 max_worker_processes            | 8       |      | default            | 8        | 8
 random_page_cost                | 4       |      | default            | 4        | 4
 seq_page_cost                   | 1       |      | default            | 1        | 1
 shared_buffers                  | 16384   | 8kB  | configuration file | 16384    | 16384
 track_functions                 | none    |      | default            | none     | none
 track_io_timing                 | off     |      | default            | off      | off
```

### 11_performance_tuning/06_function_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/11_performance_tuning/06_function_hotspots.out.txt

```text
 schema_name | function_name | calls | total_time | self_time | mean_time 
-------------+---------------+-------+------------+-----------+-----------
(0 rows)

```

### 12_planner_statistics/01_tables_needing_analyze.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/01_tables_needing_analyze.out.txt

```text
 schema_name |       table_name        | n_live_tup | n_mod_since_analyze | mods_vs_live_pct | last_analyze |       last_autoanalyze        
-------------+-------------------------+------------+---------------------+------------------+--------------+-------------------------------
 dba_metrics | index_size_snapshots    |        102 |                  34 |            33.33 |              | 2026-02-18 17:29:34.45373-05
 dba_metrics | table_size_snapshots    |         81 |                  27 |            33.33 |              | 2026-02-18 17:29:34.451723-05
 dba_metrics | database_size_snapshots |         21 |                  21 |           100.00 |              | 
 dba_metrics | connection_snapshots    |         14 |                  14 |           100.00 |              | 
 dba_metrics | wal_snapshots           |          3 |                   3 |           100.00 |              | 
(5 rows)

```

### 12_planner_statistics/02_seq_scan_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/02_seq_scan_hotspots.out.txt

```text
 schema_name |       table_name        | seq_scan | idx_scan | n_live_tup | seq_scan_pct | total_size 
-------------+-------------------------+----------+----------+------------+--------------+------------
 dba_metrics | table_size_snapshots    |        3 |          |         81 |              | 16 kB
 dba_metrics | database_size_snapshots |        3 |          |         21 |              | 16 kB
 perf        | orders                  |        0 |        0 |          0 |              | 75 MB
 dba_metrics | connection_snapshots    |        0 |          |         14 |              | 16 kB
 perf        | product_categories      |        0 |        0 |          0 |              | 2640 kB
 perf        | ticket_comments         |        0 |        0 |          0 |              | 16 kB
 perf        | tenants                 |        0 |        0 |          0 |              | 32 kB
 perf        | addresses               |        0 |        0 |          0 |              | 1576 kB
 perf        | job_runs                |        0 |        0 |          0 |              | 16 kB
 perf        | products                |        0 |        0 |          0 |              | 2232 kB
 perf        | sessions                |        0 |        0 |          0 |              | 1344 kB
 perf        | audit_log               |        0 |        0 |          0 |              | 24 kB
 dba_metrics | index_size_snapshots    |        0 |          |        102 |              | 48 kB
 perf        | documents               |        0 |        0 |          0 |              | 24 kB
 perf        | users                   |        0 |        0 |          0 |              | 4720 kB
 perf        | order_items             |        0 |        0 |          0 |              | 117 MB
 perf        | payments                |        0 |        0 |          0 |              | 83 MB
 perf        | app_events              |        0 |        0 |          0 |              | 95 MB
```

### 12_planner_statistics/03_column_stats_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/03_column_stats_profile.out.txt

```text
 schema_name |      table_name      |     column_name     | null_frac | n_distinct  | correlation  | mcv_count | histogram_bins 
-------------+----------------------+---------------------+-----------+-------------+--------------+-----------+----------------
 dba_metrics | index_size_snapshots | captured_at         |         0 |           2 |            1 |         2 |               
 dba_metrics | index_size_snapshots | idx_scan            |         0 |           1 |            1 |         1 |               
 dba_metrics | index_size_snapshots | index_bytes         |         0 |  -0.3382353 |  0.041569646 |        23 |               
 dba_metrics | index_size_snapshots | index_name          |         0 |        -0.5 |  -0.16169791 |        34 |               
 dba_metrics | index_size_snapshots | schema_name         |         0 |           2 |    0.9221285 |         2 |               
 dba_metrics | index_size_snapshots | table_name          |         0 | -0.32352942 |  -0.15192579 |        22 |               
 dba_metrics | table_size_snapshots | captured_at         |         0 |           2 |            1 |         2 |               
 dba_metrics | table_size_snapshots | estimated_dead_rows |         0 |           1 |            1 |         1 |               
 dba_metrics | table_size_snapshots | estimated_live_rows |         0 | -0.12962963 |    0.8909853 |         1 |              6
 dba_metrics | table_size_snapshots | schema_name         |         0 |           3 |    0.6920907 |         3 |               
 dba_metrics | table_size_snapshots | table_name          |         0 |        -0.5 | -0.118886985 |        27 |               
 dba_metrics | table_size_snapshots | total_bytes         |         0 | -0.33333334 |   0.18322851 |        18 |               
 public      | demo_users           | id                  |         0 |          -1 |            1 |           |            101
 public      | demo_users           | username            |         0 |           3 |   0.33481345 |         3 |               
(14 rows)

```

### 12_planner_statistics/04_extended_stats_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/04_extended_stats_candidates.out.txt

```text
 schema_name |       table_name        | column_count | write_volume | total_bytes | total_pretty | ext_stats_count | recommendation 
-------------+-------------------------+--------------+--------------+-------------+--------------+-----------------+----------------
 perf        | order_items             |            6 |            0 |   122626048 | 117 MB       |               0 | Observe
 perf        | app_events              |            6 |            0 |    99270656 | 95 MB        |               0 | Observe
 perf        | payments                |            7 |            0 |    87080960 | 83 MB        |               0 | Observe
 perf        | orders                  |            6 |            0 |    78512128 | 75 MB        |               0 | Observe
 perf        | shipments               |            6 |            0 |    19038208 | 18 MB        |               0 | Observe
 perf        | users                   |            5 |            0 |     4833280 | 4720 kB      |               0 | Observe
 public      | demo_users              |            2 |            0 |     4505600 | 4400 kB      |               0 | Observe
 perf        | inventory               |            4 |            0 |     3497984 | 3416 kB      |               0 | Observe
 perf        | product_categories      |            3 |            0 |     2703360 | 2640 kB      |               0 | Observe
 perf        | products                |            5 |            0 |     2285568 | 2232 kB      |               0 | Observe
 perf        | addresses               |            7 |            0 |     1613824 | 1576 kB      |               0 | Observe
 perf        | sessions                |            5 |            0 |     1376256 | 1344 kB      |               0 | Observe
 perf        | feature_flags           |            3 |            0 |      122880 | 120 kB       |               0 | Observe
 perf        | categories              |            3 |            0 |       98304 | 96 kB        |               0 | Observe
 dba_metrics | index_size_snapshots    |            6 |          102 |       49152 | 48 kB        |               0 | Observe
 perf        | tenants                 |            3 |            0 |       32768 | 32 kB        |               0 | Observe
 perf        | audit_log               |            8 |            0 |       24576 | 24 kB        |               0 | Observe
 perf        | documents               |            6 |            0 |       24576 | 24 kB        |               0 | Observe
```

### 12_planner_statistics/05_autovacuum_analyze_settings_by_table.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/05_autovacuum_analyze_settings_by_table.out.txt

```text
 schema_name | table_name | reloptions 
-------------+------------+------------
(0 rows)

```

### 12_planner_statistics/06_planner_cost_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/12_planner_statistics/06_planner_cost_settings.out.txt

```text
             name             | setting | unit | source  | reset_val 
------------------------------+---------+------+---------+-----------
 cpu_index_tuple_cost         | 0.005   |      | default | 0.005
 cpu_operator_cost            | 0.0025  |      | default | 0.0025
 cpu_tuple_cost               | 0.01    |      | default | 0.01
 default_statistics_target    | 100     |      | default | 100
 effective_cache_size         | 524288  | 8kB  | default | 524288
 min_parallel_index_scan_size | 64      | 8kB  | default | 64
 min_parallel_table_scan_size | 1024    | 8kB  | default | 1024
 parallel_setup_cost          | 1000    |      | default | 1000
 parallel_tuple_cost          | 0.1     |      | default | 0.1
 random_page_cost             | 4       |      | default | 4
 seq_page_cost                | 1       |      | default | 1
(11 rows)

```

### 13_io_wal_checkpoints/01_database_io_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/01_database_io_profile.out.txt

```text
           database_name           | numbackends | xact_commit | xact_rollback | blks_read | blks_hit  | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | stats_reset 
-----------------------------------+-------------+-------------+---------------+-----------+-----------+--------------+-------------+--------------+-------------+-------------+------------+------------+-----------+---------------+----------------+-------------
 pgbench_test                      |           0 |     5349080 |             2 |  14208247 | 141642704 |    230081965 |    21510954 |    205355320 |    15999071 |         289 |          6 | 4008443904 |         0 |             0 |              0 | 
 hypopg_lab                        |           0 |        8351 |             0 |      4016 |    317959 |      3777902 |       69755 |          370 |          59 |         275 |          0 |          0 |         0 |             0 |              0 | 
 appdb                             |           2 |        9030 |             9 |      1541 |    326701 |      3718028 |       76017 |          417 |          55 |         275 |          0 |          0 |         0 |             0 |              0 | 
 postgres                          |           2 |        8929 |             8 |      1476 |    387431 |      3805930 |      110574 |          476 |          69 |         462 |          0 |          0 |         0 |             0 |              0 | 
 perf_test                         |           0 |        8361 |             2 |      1103 |    316753 |      4669781 |       69497 |          369 |          29 |         274 |          0 |          0 |         0 |             0 |              0 | 
 script_validation_20260218_172749 |           1 |        1016 |            24 |       296 |    477195 |       680015 |      300636 |          745 |          44 |         294 |          0 |          0 |         0 |             0 |              0 | 
(6 rows)

```

### 13_io_wal_checkpoints/02_table_io_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/02_table_io_hotspots.out.txt

```text
 schema_name |       table_name        | heap_blks_read | heap_blks_hit | idx_blks_read | idx_blks_hit | toast_blks_read | toast_blks_hit | tidx_blks_read | tidx_blks_hit | total_size 
-------------+-------------------------+----------------+---------------+---------------+--------------+-----------------+----------------+----------------+---------------+------------
 dba_metrics | table_size_snapshots    |              0 |            84 |               |              |               0 |              0 |              0 |             0 | 16 kB
 dba_metrics | index_size_snapshots    |              0 |           103 |               |              |               0 |              0 |              0 |             0 | 48 kB
 dba_metrics | connection_snapshots    |              0 |            13 |               |              |               0 |              0 |              0 |             0 | 16 kB
 dba_metrics | database_size_snapshots |              0 |            23 |               |              |               0 |              0 |              0 |             0 | 16 kB
 dba_metrics | wal_snapshots           |              0 |             2 |               |              |               0 |              0 |              0 |             0 | 16 kB
 perf        | product_categories      |              0 |             0 |             0 |            0 |                 |                |                |               | 2640 kB
 perf        | orders                  |              0 |             0 |             0 |            0 |                 |                |                |               | 75 MB
 perf        | order_items             |              0 |             0 |             0 |            0 |                 |                |                |               | 117 MB
 perf        | shipments               |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 18 MB
 perf        | app_events              |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 95 MB
 perf        | audit_log               |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 24 kB
 perf        | documents               |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 24 kB
 perf        | addresses               |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 1576 kB
 perf        | tenants                 |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 32 kB
 perf        | feature_flags           |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 120 kB
 perf        | inventory               |              0 |             0 |             0 |            0 |                 |                |                |               | 3416 kB
 perf        | support_tickets         |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 16 kB
 perf        | ticket_comments         |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 16 kB
```

### 13_io_wal_checkpoints/03_index_io_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/03_index_io_hotspots.out.txt

```text
 schema_name |     table_name     |                  index_name                  | idx_blks_read | idx_blks_hit | index_size 
-------------+--------------------+----------------------------------------------+---------------+--------------+------------
 perf        | tenants            | tenants_pkey                                 |             0 |            0 | 16 kB
 perf        | users              | users_pkey                                   |             0 |            0 | 2208 kB
 perf        | products           | products_pkey                                |             0 |            0 | 2208 kB
 perf        | categories         | categories_pkey                              |             0 |            0 | 72 kB
 perf        | product_categories | product_categories_pkey                      |             0 |            0 | 2624 kB
 perf        | orders             | orders_pkey                                  |             0 |            0 | 20 MB
 perf        | order_items        | order_items_pkey                             |             0 |            0 | 60 MB
 perf        | payments           | payments_pkey                                |             0 |            0 | 20 MB
 perf        | shipments          | shipments_pkey                               |             0 |            0 | 18 MB
 perf        | app_events         | app_events_pkey                              |             0 |            0 | 54 MB
 perf        | audit_log          | audit_log_pkey                               |             0 |            0 | 8192 bytes
 perf        | documents          | documents_pkey                               |             0 |            0 | 8192 bytes
 perf        | addresses          | addresses_pkey                               |             0 |            0 | 1552 kB
 perf        | sessions           | sessions_pkey                                |             0 |            0 | 1328 kB
 perf        | feature_flags      | feature_flags_pkey                           |             0 |            0 | 96 kB
 perf        | inventory          | inventory_pkey                               |             0 |            0 | 3400 kB
 perf        | support_tickets    | support_tickets_pkey                         |             0 |            0 | 8192 bytes
 perf        | ticket_comments    | ticket_comments_pkey                         |             0 |            0 | 8192 bytes
```

### 13_io_wal_checkpoints/04_wal_archiver_health.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/04_wal_archiver_health.out.txt

```text
 archived_count | last_archived_wal | last_archived_time | failed_count | last_failed_wal | last_failed_time |          stats_reset          
----------------+-------------------+--------------------+--------------+-----------------+------------------+-------------------------------
              0 |                   |                    |            0 |                 |                  | 2026-01-31 20:40:48.109778-05
(1 row)

```

### 13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/05_checkpoint_pressure_indicators.out.txt

```text
 checkpoints_timed | checkpoints_req | requested_checkpoint_pct | checkpoint_write_time | checkpoint_sync_time | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_alloc |   checkpointer_stats_reset    |     bgwriter_stats_reset      
-------------------+-----------------+--------------------------+-----------------------+----------------------+--------------------+--------------+---------------+------------------+---------------+-------------------------------+-------------------------------
               826 |              59 |                     6.67 |               2788826 |                48655 |              27276 |          210 |        244345 |             2422 |      10825264 | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
(1 row)

```

### 13_io_wal_checkpoints/06_temp_file_usage_by_database.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/06_temp_file_usage_by_database.out.txt

```text
           database_name           | temp_files | temp_bytes | temp_pretty | xact_commit | xact_rollback | stats_reset 
-----------------------------------+------------+------------+-------------+-------------+---------------+-------------
 pgbench_test                      |          6 | 4008443904 | 3823 MB     |     5349080 |             2 | 
 postgres                          |          0 |          0 | 0 bytes     |        8929 |             8 | 
 perf_test                         |          0 |          0 | 0 bytes     |        8361 |             2 | 
 appdb                             |          0 |          0 | 0 bytes     |        9030 |             9 | 
 hypopg_lab                        |          0 |          0 | 0 bytes     |        8351 |             0 | 
 script_validation_20260218_172749 |          0 |          0 | 0 bytes     |        1026 |            24 | 
(6 rows)

```

### 13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql
- Status: PASS
- Exit code: 0
- Output file: out/13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.out.txt

```text
    backend_type     |    object     |  context  |  reads   | read_time | writes  | write_time | writebacks | writeback_time | extends | extend_time | fsyncs | fsync_time 
---------------------+---------------+-----------+----------+-----------+---------+------------+------------+----------------+---------+-------------+--------+------------
 io worker           | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
 client backend      | relation      | bulkwrite |        0 |         0 | 3722888 |          0 |          0 |              0 |   57650 |           0 |        |           
 client backend      | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
 client backend      | relation      | normal    | 10690038 |         0 | 7858524 |          0 |          0 |              0 |   26878 |           0 |      0 |          0
 client backend      | relation      | vacuum    |    87279 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
 client backend      | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |      10 |           0 |        |           
 slotsync worker     | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |       0 |           0 |        |           
 slotsync worker     | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
 standalone backend  | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
 standalone backend  | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
 standalone backend  | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
 standalone backend  | relation      | normal    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
 standalone backend  | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
 standalone backend  | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
 checkpointer        | wal           | normal    |        0 |         0 |     120 |          0 |            |                |         |             |      0 |          0
 io worker           | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
 io worker           | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
 client backend      | relation      | bulkread  |   119076 |         0 |    1039 |          0 |          0 |              0 |         |             |        |           
```

### 14_connection_workload/01_connections_by_user_app_db.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/01_connections_by_user_app_db.out.txt

```text
           database_name           | user_name | application_name | state  | connection_count 
-----------------------------------+-----------+------------------+--------+------------------
                                   |           |                  |        |                7
 appdb                             | saiendla  | dbvis            | idle   |                2
 postgres                          | saiendla  | dbvis            | idle   |                1
 postgres                          | saiendla  | psql             | idle   |                1
 script_validation_20260218_172749 | saiendla  | psql             | active |                1
                                   | saiendla  |                  |        |                1
(6 rows)

```

### 14_connection_workload/02_idle_in_transaction_risk.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/02_idle_in_transaction_risk.out.txt

```text
 pid | database_name | user_name | application_name | client_addr | xact_start | state_change | xact_age | idle_in_txn_age | wait_event_type | wait_event | query_snippet 
-----+---------------+-----------+------------------+-------------+------------+--------------+----------+-----------------+-----------------+------------+---------------
(0 rows)

```

### 14_connection_workload/03_connection_state_distribution.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/03_connection_state_distribution.out.txt

```text
 state  | session_count |      oldest_query_start       |      newest_query_start       | avg_query_age_seconds  
--------+---------------+-------------------------------+-------------------------------+------------------------
        |             8 |                               |                               |                       
 idle   |             4 | 2026-02-18 16:44:24.420894-05 | 2026-02-18 17:30:53.560003-05 |  1022.1118030000000000
 active |             1 | 2026-02-18 17:36:13.264364-05 | 2026-02-18 17:36:13.264364-05 | 0.00000000000000000000
(3 rows)

```

### 14_connection_workload/04_role_connection_limit_risk.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/04_role_connection_limit_risk.out.txt

```text
 role_name | rolconnlimit | current_connections | pct_of_role_limit 
-----------+--------------+---------------------+-------------------
 saiendla  |           -1 |                   6 |                  
 postgres  |           -1 |                   0 |                  
(2 rows)

```

### 14_connection_workload/05_backend_type_distribution.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/05_backend_type_distribution.out.txt

```text
         backend_type         | backend_count 
------------------------------+---------------
 client backend               |             5
 io worker                    |             3
 autovacuum launcher          |             1
 background writer            |             1
 checkpointer                 |             1
 logical replication launcher |             1
 walwriter                    |             1
(7 rows)

```

### 14_connection_workload/06_prepared_transactions_status.sql
- Status: PASS
- Exit code: 0
- Output file: out/14_connection_workload/06_prepared_transactions_status.out.txt

```text
 transaction | gid | prepared | owner | database | prepared_age 
-------------+-----+----------+-------+----------+--------------
(0 rows)

```

### 15_capacity_forecasting/01_create_capacity_repository.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/01_create_capacity_repository.out.txt

```text
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:6: NOTICE:  schema "dba_metrics" already exists, skipping
CREATE SCHEMA
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:12: NOTICE:  relation "database_size_snapshots" already exists, skipping
CREATE TABLE
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:21: NOTICE:  relation "table_size_snapshots" already exists, skipping
CREATE TABLE
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:30: NOTICE:  relation "index_size_snapshots" already exists, skipping
CREATE TABLE
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:39: NOTICE:  relation "connection_snapshots" already exists, skipping
CREATE TABLE
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/15_capacity_forecasting/01_create_capacity_repository.sql:47: NOTICE:  relation "wal_snapshots" already exists, skipping
CREATE TABLE
```

### 15_capacity_forecasting/02_capture_database_size_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/02_capture_database_size_snapshot.out.txt

```text
INSERT 0 7
```

### 15_capacity_forecasting/03_capture_table_size_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/03_capture_table_size_snapshot.out.txt

```text
INSERT 0 27
```

### 15_capacity_forecasting/04_capture_index_size_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/04_capture_index_size_snapshot.out.txt

```text
INSERT 0 34
```

### 15_capacity_forecasting/05_capture_connection_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/05_capture_connection_snapshot.out.txt

```text
INSERT 0 6
```

### 15_capacity_forecasting/06_capture_wal_snapshot.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/06_capture_wal_snapshot.out.txt

```text
INSERT 0 1
```

### 15_capacity_forecasting/07_database_growth_report.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/07_database_growth_report.out.txt

```text
           database_name           |       first_captured_at       |       last_captured_at        | first_size_bytes | last_size_bytes | growth_bytes | growth_pretty | growth_bytes_per_second 
-----------------------------------+-------------------------------+-------------------------------+------------------+-----------------+--------------+---------------+-------------------------
 script_validation_20260218_172749 | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |        436508351 |       436623039 |       114688 | 112 kB        |                  253.99
 appdb                             | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |          8050367 |         8066751 |        16384 | 16 kB         |                   36.28
 perf_test                         | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |        436410047 |       436410047 |            0 | 0 bytes       |                    0.00
 postgres                          | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |          8140479 |         8140479 |            0 | 0 bytes       |                    0.00
 template1                         | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |          8033983 |         8033983 |            0 | 0 bytes       |                    0.00
 pgbench_test                      | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |      32018454207 |     32018454207 |            0 | 0 bytes       |                    0.00
 hypopg_lab                        | 2026-02-18 17:28:41.820883-05 | 2026-02-18 17:36:13.370406-05 |         36173503 |        36173503 |            0 | 0 bytes       |                    0.00
(7 rows)

```

### 15_capacity_forecasting/08_table_growth_report.sql
- Status: PASS
- Exit code: 0
- Output file: out/15_capacity_forecasting/08_table_growth_report.out.txt

```text
 schema_name |       table_name        |       first_captured_at       |       last_captured_at        | first_bytes | last_bytes | growth_bytes | growth_pretty 
-------------+-------------------------+-------------------------------+-------------------------------+-------------+------------+--------------+---------------
 dba_metrics | index_size_snapshots    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |        8192 |      49152 |        40960 | 40 kB
 dba_metrics | wal_snapshots           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |        8192 |      16384 |         8192 | 8192 bytes
 dba_metrics | connection_snapshots    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |        8192 |      16384 |         8192 | 8192 bytes
 perf        | addresses               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |     1613824 |    1613824 |            0 | 0 bytes
 perf        | app_events              | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |    99270656 |   99270656 |            0 | 0 bytes
 perf        | audit_log               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       24576 |      24576 |            0 | 0 bytes
 perf        | categories              | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       98304 |      98304 |            0 | 0 bytes
 perf        | documents               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       24576 |      24576 |            0 | 0 bytes
 perf        | feature_flags           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |      122880 |     122880 |            0 | 0 bytes
 perf        | inventory               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |     3497984 |    3497984 |            0 | 0 bytes
 perf        | job_runs                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       16384 |      16384 |            0 | 0 bytes
 perf        | jobs                    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       16384 |      16384 |            0 | 0 bytes
 perf        | notifications           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |       16384 |      16384 |            0 | 0 bytes
 perf        | order_items             | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |   122626048 |  122626048 |            0 | 0 bytes
 perf        | orders                  | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |    78512128 |   78512128 |            0 | 0 bytes
 perf        | payments                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |    87080960 |   87080960 |            0 | 0 bytes
 perf        | product_categories      | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |     2703360 |    2703360 |            0 | 0 bytes
 perf        | products                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:36:13.397487-05 |     2285568 |    2285568 |            0 | 0 bytes
```

### 16_internals_deep_dive/01_database_xid_multixact_age.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/01_database_xid_multixact_age.out.txt

```text
           database_name           | xid_age | multixact_age | datconnlimit | datallowconn 
-----------------------------------+---------+---------------+--------------+--------------
 postgres                          | 5333116 |             0 |           -1 | t
 perf_test                         | 5333116 |             0 |           -1 | t
 template1                         | 5333116 |             0 |           -1 | t
 template0                         | 5333116 |             0 |           -1 | f
 appdb                             | 5333116 |             0 |           -1 | t
 hypopg_lab                        | 5333116 |             0 |           -1 | t
 pgbench_test                      | 5333116 |             0 |           -1 | t
 script_validation_20260218_172749 | 5333116 |             0 |           -1 | t
(8 rows)

```

### 16_internals_deep_dive/02_relation_filenode_mapping.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/02_relation_filenode_mapping.out.txt

```text
 schema_name |                relation_name                 | relkind | relation_oid | relfilenode | reltablespace | relation_filepath 
-------------+----------------------------------------------+---------+--------------+-------------+---------------+-------------------
 dba_metrics | connection_snapshots                         | r       |        25410 |       25410 |             0 | base/25378/25410
 dba_metrics | database_size_snapshots                      | r       |        25380 |       25380 |             0 | base/25378/25380
 dba_metrics | index_size_snapshots                         | r       |        25399 |       25399 |             0 | base/25378/25399
 dba_metrics | table_size_snapshots                         | r       |        25389 |       25389 |             0 | base/25378/25389
 dba_metrics | wal_snapshots                                | r       |        25418 |       25418 |             0 | base/25378/25418
 perf        | addresses                                    | r       |        16604 |       16604 |             0 | base/25378/16604
 perf        | addresses_address_id_seq                     | S       |        16603 |       16603 |             0 | base/25378/16603
 perf        | addresses_pkey                               | i       |        16617 |       16617 |             0 | base/25378/16617
 perf        | app_events                                   | r       |        16562 |       16562 |             0 | base/25378/16562
 perf        | app_events_event_id_seq                      | S       |        16561 |       16561 |             0 | base/25378/16561
 perf        | app_events_pkey                              | i       |        16573 |       16573 |             0 | base/25378/16573
 perf        | app_events_tenant_id_event_ts_idx            | i       |        16761 |       16761 |             0 | base/25378/16761
 perf        | app_events_tenant_id_event_type_event_ts_idx | i       |        16762 |       16762 |             0 | base/25378/16762
 perf        | audit_log                                    | r       |        16576 |       16576 |             0 | base/25378/16576
 perf        | audit_log_audit_id_seq                       | S       |        16575 |       16575 |             0 | base/25378/16575
 perf        | audit_log_pkey                               | i       |        16587 |       16587 |             0 | base/25378/16587
 perf        | audit_log_tenant_id_audit_ts_idx             | i       |        16764 |       16764 |             0 | base/25378/16764
 perf        | categories                                   | r       |        16444 |       16444 |             0 | base/25378/16444
```

### 16_internals_deep_dive/03_system_catalog_size_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/03_system_catalog_size_profile.out.txt

```text
    schema_name     |                  catalog_name                  | relkind | total_bytes | total_pretty 
--------------------+------------------------------------------------+---------+-------------+--------------
 pg_catalog         | pg_proc                                        | r       |     1302528 | 1272 kB
 pg_catalog         | pg_attribute                                   | r       |      942080 | 920 kB
 pg_catalog         | pg_rewrite                                     | r       |      778240 | 760 kB
 pg_catalog         | pg_description                                 | r       |      638976 | 624 kB
 pg_catalog         | pg_depend                                      | r       |      409600 | 400 kB
 pg_catalog         | pg_statistic                                   | r       |      376832 | 368 kB
 pg_catalog         | pg_collation                                   | r       |      360448 | 352 kB
 pg_catalog         | pg_proc_proname_args_nsp_index                 | i       |      270336 | 264 kB
 pg_catalog         | pg_constraint                                  | r       |      262144 | 256 kB
 pg_catalog         | pg_class                                       | r       |      262144 | 256 kB
 pg_catalog         | pg_type                                        | r       |      262144 | 256 kB
 pg_catalog         | pg_operator                                    | r       |      237568 | 232 kB
 pg_catalog         | pg_amop                                        | r       |      229376 | 224 kB
 pg_catalog         | pg_description_o_c_o_index                     | i       |      221184 | 216 kB
 pg_catalog         | pg_attribute_relid_attnam_index                | i       |      172032 | 168 kB
 pg_catalog         | pg_amproc                                      | r       |      147456 | 144 kB
 pg_catalog         | pg_depend_depender_index                       | i       |      131072 | 128 kB
 pg_catalog         | pg_attribute_relid_attnum_index                | i       |      114688 | 112 kB
```

### 16_internals_deep_dive/04_dependency_fanout_objects.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/04_dependency_fanout_objects.out.txt

```text
 object_oid | schema_name |                 object_name                  | relkind | dependency_count 
------------+-------------+----------------------------------------------+---------+------------------
      16479 | perf        | orders                                       | r       |               20
      16404 | perf        | users                                        | r       |               20
      16562 | perf        | app_events                                   | r       |               15
      16525 | perf        | payments                                     | r       |               15
      16424 | perf        | products                                     | r       |               15
      16502 | perf        | order_items                                  | r       |               14
      16604 | perf        | addresses                                    | r       |               13
      16665 | perf        | support_tickets                              | r       |               13
      16391 | perf        | tenants                                      | r       |               13
      16576 | perf        | audit_log                                    | r       |               12
      16590 | perf        | documents                                    | r       |               12
      16704 | perf        | notifications                                | r       |               12
      16738 | perf        | job_runs                                     | r       |               11
      16724 | perf        | jobs                                         | r       |               11
      16685 | perf        | ticket_comments                              | r       |               11
      16444 | perf        | categories                                   | r       |               10
      16544 | perf        | shipments                                    | r       |               10
      16460 | perf        | product_categories                           | r       |                9
```

### 16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.out.txt

```text
 schema_name |       table_name        | main_bytes | fsm_bytes | vm_bytes | toast_total_bytes | table_total_bytes | table_total_pretty 
-------------+-------------------------+------------+-----------+----------+-------------------+-------------------+--------------------
 perf        | order_items             |          0 |     16384 |        0 |                 0 |         122626048 | 117 MB
 perf        | app_events              |          0 |     16384 |        0 |              8192 |          99270656 | 95 MB
 perf        | payments                |          0 |     16384 |        0 |                 0 |          87080960 | 83 MB
 perf        | orders                  |          0 |     16384 |        0 |                 0 |          78512128 | 75 MB
 perf        | shipments               |          0 |     16384 |        0 |              8192 |          19038208 | 18 MB
 perf        | users                   |          0 |     16384 |        0 |              8192 |           4833280 | 4720 kB
 public      | demo_users              |    2220032 |     24576 |     8192 |              8192 |           4505600 | 4400 kB
 perf        | inventory               |          0 |     16384 |        0 |                 0 |           3497984 | 3416 kB
 perf        | product_categories      |          0 |     16384 |        0 |                 0 |           2703360 | 2640 kB
 perf        | products                |          0 |     16384 |        0 |              8192 |           2285568 | 2232 kB
 perf        | addresses               |          0 |     16384 |        0 |              8192 |           1613824 | 1576 kB
 perf        | sessions                |          0 |     16384 |        0 |                 0 |           1376256 | 1344 kB
 perf        | feature_flags           |          0 |     16384 |        0 |              8192 |            122880 | 120 kB
 perf        | categories              |          0 |     16384 |        0 |              8192 |             98304 | 96 kB
 dba_metrics | index_size_snapshots    |      16384 |     24576 |        0 |              8192 |             49152 | 48 kB
 dba_metrics | table_size_snapshots    |      16384 |     24576 |        0 |              8192 |             49152 | 48 kB
 perf        | tenants                 |       8192 |         0 |        0 |              8192 |             32768 | 32 kB
 perf        | audit_log               |          0 |         0 |        0 |              8192 |             24576 | 24 kB
```

### 16_internals_deep_dive/06_visibility_and_freeze_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/16_internals_deep_dive/06_visibility_and_freeze_profile.out.txt

```text
 schema_name |       table_name        | relfrozenxid | relfrozenxid_age | relminmxid | relminmxid_age | relpages | reltuples | total_size 
-------------+-------------------------+--------------+------------------+------------+----------------+----------+-----------+------------
 perf        | tenants                 |          765 |          5333095 |          1 |              0 |        0 |        -1 | 32 kB
 perf        | audit_log               |          775 |          5333085 |          1 |              0 |        0 |        -1 | 24 kB
 perf        | documents               |          776 |          5333084 |          1 |              0 |        0 |        -1 | 24 kB
 perf        | support_tickets         |          781 |          5333079 |          1 |              0 |        0 |        -1 | 16 kB
 perf        | ticket_comments         |          782 |          5333078 |          1 |              0 |        0 |        -1 | 16 kB
 perf        | notifications           |          783 |          5333077 |          1 |              0 |        0 |        -1 | 16 kB
 perf        | jobs                    |          784 |          5333076 |          1 |              0 |        0 |        -1 | 16 kB
 perf        | job_runs                |          785 |          5333075 |          1 |              0 |        0 |        -1 | 16 kB
 perf        | users                   |          801 |          5333059 |          1 |              0 |        0 |         0 | 4720 kB
 perf        | products                |          802 |          5333058 |          1 |              0 |        0 |         0 | 2232 kB
 perf        | payments                |          803 |          5333057 |          1 |              0 |        0 |         0 | 83 MB
 perf        | categories              |          804 |          5333056 |          1 |              0 |        0 |         0 | 96 kB
 perf        | product_categories      |          805 |          5333055 |          1 |              0 |        0 |         0 | 2640 kB
 perf        | orders                  |          806 |          5333054 |          1 |              0 |        0 |         0 | 75 MB
 perf        | order_items             |          806 |          5333054 |          1 |              0 |        0 |         0 | 117 MB
 perf        | shipments               |          807 |          5333053 |          1 |              0 |        0 |         0 | 18 MB
 perf        | addresses               |          808 |          5333052 |          1 |              0 |        0 |         0 | 1576 kB
 perf        | app_events              |          808 |          5333052 |          1 |              0 |        0 |         0 | 95 MB
```

### 17_execution_plans/01_plan_capture_prerequisites.sql
- Status: PASS
- Exit code: 0
- Output file: out/17_execution_plans/01_plan_capture_prerequisites.out.txt

```text
            name            |      setting       | unit |       source       | boot_val |     reset_val      
----------------------------+--------------------+------+--------------------+----------+--------------------
 compute_query_id           | auto               |      | default            | auto     | auto
 jit                        | on                 |      | default            | on       | on
 log_min_duration_statement | -1                 | ms   | default            | -1       | -1
 plan_cache_mode            | auto               |      | default            | auto     | auto
 shared_preload_libraries   | pg_stat_statements |      | configuration file |          | pg_stat_statements
 track_activity_query_size  | 1024               | B    | default            | 1024     | 1024
 track_io_timing            | off                |      | default            | off      | off
(7 rows)

```

### 17_execution_plans/02_explain_analyze_template.sql
- Status: PASS
- Exit code: 0
- Output file: out/17_execution_plans/02_explain_analyze_template.out.txt

```text
                                      QUERY PLAN                                       
---------------------------------------------------------------------------------------
 Result  (cost=0.00..0.01 rows=1 width=4) (actual time=0.001..0.001 rows=1.00 loops=1)
   Output: 1
 Query Identifier: -3688696628780506391
 Planning:
   Buffers: shared hit=3
 Planning Time: 0.049 ms
 Execution Time: 0.029 ms
(7 rows)

```

### 17_execution_plans/03_generate_explain_for_top_queries.sql
- Status: PASS
- Exit code: 0
- Output file: out/17_execution_plans/03_generate_explain_for_top_queries.out.txt

```text
       queryid        |  calls  |  total_exec_time   |     mean_exec_time     |                                                                                    query_snippet                                                                                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             explain_sql                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
----------------------+---------+--------------------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 | 20318063.253471453 |     3.8100014295381928 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2                                                                                                                  | /* queryid=1144016440436625022 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2;
 -5371882943115234533 | 5332823 |  440938.2827256841 |    0.08268383982104996 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2                                                                                                                  | /* queryid=-5371882943115234533 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2;
  -305747636952590102 | 5332823 | 209356.47065673055 |   0.039258094757131864 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2                                                                                                                   | /* queryid=-305747636952590102 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2;
  3387776431457662738 | 5332823 | 107882.85510483896 |   0.020229971087544072 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)                                                                                 | /* queryid=3387776431457662738 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP);
 -1078345578982625442 | 5332823 |  36480.01148695377 |   0.006840656719152106 | SELECT abalance FROM pgbench_accounts WHERE aid = $1                                                                                                                                 | /* queryid=-1078345578982625442 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) SELECT abalance FROM pgbench_accounts WHERE aid = $1;
  3481893718825960883 |    7109 |  20055.74470699987 |     2.8211766362357635 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                    +| /* queryid=3481893718825960883 */ EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS) SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               +
                      |         |                    |                        | FROM (SELECT                                                                                                                                                                        +| FROM (SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                    |                        |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.p                                                                               |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       +
                      |         |                    |                        |                                                                                                                                                                                      |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      +
                      |         |                    |                        |                                                                                                                                                                                      |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $6))  AS "Idle"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         +
                      |         |                    |                        |                                                                                                                                                                                      | ) t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 +
                      |         |                    |                        |                                                                                                                                                                                      | UNION ALL                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           +
                      |         |                    |                        |                                                                                                                                                                                      | SELECT $7 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    +
                      |         |                    |                        |                                                                                                                                                                                      | FROM (SELECT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                    |                        |                                                                                                                                                                                      |    (SELECT sum(xact_commit) + sum(xact_rollback) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $8)) AS "Transactions",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   +
                      |         |                    |                        |                                                                                                                                                                                      |    (SELECT sum(xact_commit) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $9)) AS "Commits",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             +
                      |         |                    |                        |                                                                                                                                                                                      |    (SELECT sum(xact_rollback) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $10)) AS "Rollbacks"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         +
                      |         |                    |                        |                                                                                                                                                                                      | ) t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 +
```

### 17_execution_plans/04_plan_red_flag_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/17_execution_plans/04_plan_red_flag_candidates.out.txt

```text
       queryid        |  calls  |   total_exec_time   |     mean_exec_time     |   stddev_exec_time    | shared_blks_hit | shared_blks_read | temp_blks_written |         recommendation         |                                                                                                        query_snippet                                                                                                         
----------------------+---------+---------------------+------------------------+-----------------------+-----------------+------------------+-------------------+--------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |  20318063.253471453 |     3.8100014295381928 |     92.32002420399405 |        45639018 |         10664795 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |   440938.2827256841 |    0.08268383982104996 |    2.0963843383810876 |        30081894 |             1205 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 |  209356.47065673055 |   0.039258094757131864 |     0.625514976433878 |        27087536 |             1533 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 |  107882.85510483896 |   0.020229971087544072 |    2.4970450599666827 |         5534382 |            19313 |                 0 | Unstable plan/runtime variance | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |   36480.01148695377 |   0.006840656719152106 |   0.05010911945496172 |        29324806 |               55 |                 0 | Unstable plan/runtime variance | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |   20055.74470699987 |     2.8211766362357635 |    117.82179113781538 |          216589 |               97 |                 0 | Unstable plan/runtime variance | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                            +
                      |         |                     |                        |                       |                 |                  |                   |                                | FROM (SELECT                                                                                                                                                                                                                +
                      |         |                     |                        |                       |                 |                  |                   |                                |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                               +
                      |         |                     |                        |                       |                 |                  |                   |                                | 
   450201137788272562 |       1 |         1674.504167 |            1674.504167 |                     0 |            9664 |            29989 |                 0 | I/O heavy plan risk            | ANALYZE
 -5398677000037045473 |       1 |          802.498625 |             802.498625 |                     0 |             238 |            53105 |                 0 | I/O heavy plan risk            | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
  6097083398544187049 | 5332823 |   610.4023310318215 | 0.00011446138958671586 |   0.00335278765645261 |               0 |                0 |                 0 | Unstable plan/runtime variance | END
  4854991825702068830 | 5332823 |    599.397160031148 | 0.00011239772255708013 | 0.0021783571257651454 |               0 |                0 |                 0 | Unstable plan/runtime variance | BEGIN
  4640742184386830055 |      63 |          155.489831 |     2.4680925555555544 |    1.0937281720904906 |             559 |                8 |                 0 | Observe                        | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  8710856124765966157 |       4 |          133.557624 |              33.389406 |    3.8411854852449525 |           16860 |               48 |                 0 | Observe                        | SELECT                                                                                                                                                                                                                      +
                      |         |                     |                        |                       |                 |                  |                   |                                |     n.nspname AS schema_name,                                                                                                                                                                                               +
                      |         |                     |                        |                       |                 |                  |                   |                                |     c.relname AS catalog_name,                                                                                                                                                                                              +
                      |         |                     |                        |                       |                 |                  |                   |                                |     c.relkind,                                                                                                                                                                                                              +
```

### 18_long_queries_full_scans/01_active_long_queries.sql
- Status: PASS
- Exit code: 0
- Output file: out/18_long_queries_full_scans/01_active_long_queries.out.txt

```text
 pid | database_name | user_name | application_name | client_addr | query_age | state | wait_event_type | wait_event | query_snippet 
-----+---------------+-----------+------------------+-------------+-----------+-------+-----------------+------------+---------------
(0 rows)

```

### 18_long_queries_full_scans/02_long_queries_from_statements.sql
- Status: PASS
- Exit code: 0
- Output file: out/18_long_queries_full_scans/02_long_queries_from_statements.out.txt

```text
       queryid        |  calls  |   total_exec_time   |     mean_exec_time     |     min_exec_time     |    max_exec_time    | shared_blks_read | temp_blks_written |                                                                                                                                                                                                  query_snippet                                                                                                                                                                                                   
----------------------+---------+---------------------+------------------------+-----------------------+---------------------+------------------+-------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  2803908607325963314 |       5 |           26.389584 |              5.2779168 |              4.066125 |            6.863792 |                1 |                 0 | CREATE TEMP TABLE tmp_pg360_check_results (                                                                                                                                                                                                                                                                                                                                                                     +
                      |         |                     |                        |                       |                     |                  |                   |     check_id text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                                     +
                      |         |                     |                        |                       |                     |                  |                   |     area text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                                         +
                      |         |                     |                        |                       |                     |                  |                   |     severity_if_failing text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                          +
                      |         |                     |                        |                       |                     |                  |                   |     status text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                                       +
                      |         |                     |                        |                       |                     |                  |                   |     issue_count bigint NOT NULL,                                                                                                                                                                                                                                                                                                                                                                                +
                      |         |                     |                        |                       |                     |                  |                   |     threshold_rule text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                               +
                      |         |                     |                        |                       |                     |                  |                   |     evidence text NOT NULL,                                                                                                                                                                                                                                                                                                                                                                                     +
                      |         |                     |                        |                       |                     |                  |                   |     recommended_fix text NOT NULL                                                                                                                                                                                                                                                                                                                                                                               +
                      |         |                     |                        |                       |                     |                  |                   | )
  1144016440436625022 | 5332823 |  20318063.253471453 |     3.8100014295381928 |  0.005416000000000001 |         8598.566083 |         10664795 |                 0 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
  3481893718825960883 |    7109 |   20055.74470699987 |     2.8211766362357635 |              0.191207 |         8578.898084 |               97 |                 0 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                                                                                +
                      |         |                     |                        |                       |                     |                  |                   | FROM (SELECT                                                                                                                                                                                                                                                                                                                                                                                                    +
                      |         |                     |                        |                       |                     |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                                                                                                                                                   +
                      |         |                     |                        |                       |                     |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",                                                                                                                                                                                                                                                  +
                      |         |                     |                        |                       |                     |                  |                   |    (SELECT count(*) F
  4640742184386830055 |      63 |          155.489831 |     2.4680925555555544 |              1.108875 |            9.759916 |                8 |                 0 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
 -8685382285450836017 |       8 |  14.667250000000001 |             1.83340625 |              1.411251 |            2.892084 |                0 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                                                                                                          +
```

### 18_long_queries_full_scans/03_short_vs_long_query_distribution.sql
- Status: PASS
- Exit code: 0
- Output file: out/18_long_queries_full_scans/03_short_vs_long_query_distribution.out.txt

```text
      bucket       | statement_count | total_calls | total_exec_time_ms 
-------------------+-----------------+-------------+--------------------
 Short (<10ms)     |             272 |    37339954 | 21135097.383731738
 Medium (10-100ms) |              14 |          35 |         699.973162
 Long (100ms-1s)   |               1 |           1 |         802.498625
 Very long (>1s)   |               1 |           1 |        1674.504167
(4 rows)

```

### 18_long_queries_full_scans/04_full_scan_hotspot_tables.sql
- Status: PASS
- Exit code: 0
- Output file: out/18_long_queries_full_scans/04_full_scan_hotspot_tables.out.txt

```text
 schema_name | table_name | seq_scan | idx_scan | seq_scan_pct | total_bytes | total_pretty | estimated_live_rows 
-------------+------------+----------+----------+--------------+-------------+--------------+---------------------
(0 rows)

```

### 19_dml_optimization/01_write_heavy_tables.sql
- Status: PASS
- Exit code: 0
- Output file: out/19_dml_optimization/01_write_heavy_tables.out.txt

```text
 schema_name |       table_name        | n_tup_ins | n_tup_upd | n_tup_del | total_writes | n_live_tup | n_dead_tup | total_size 
-------------+-------------------------+-----------+-----------+-----------+--------------+------------+------------+------------
 dba_metrics | index_size_snapshots    |       136 |         0 |         0 |          136 |        136 |          0 | 48 kB
 dba_metrics | table_size_snapshots    |       108 |         0 |         0 |          108 |        108 |          0 | 48 kB
 dba_metrics | database_size_snapshots |        28 |         0 |         0 |           28 |         28 |          0 | 16 kB
 dba_metrics | connection_snapshots    |        20 |         0 |         0 |           20 |         20 |          0 | 16 kB
 dba_metrics | wal_snapshots           |         4 |         0 |         0 |            4 |          4 |          0 | 16 kB
 perf        | tenants                 |         0 |         0 |         0 |            0 |          0 |          0 | 32 kB
 perf        | addresses               |         0 |         0 |         0 |            0 |          0 |          0 | 1576 kB
 perf        | job_runs                |         0 |         0 |         0 |            0 |          0 |          0 | 16 kB
 perf        | products                |         0 |         0 |         0 |            0 |          0 |          0 | 2232 kB
 perf        | sessions                |         0 |         0 |         0 |            0 |          0 |          0 | 1344 kB
 perf        | audit_log               |         0 |         0 |         0 |            0 |          0 |          0 | 24 kB
 perf        | documents               |         0 |         0 |         0 |            0 |          0 |          0 | 24 kB
 perf        | users                   |         0 |         0 |         0 |            0 |          0 |          0 | 4720 kB
 perf        | order_items             |         0 |         0 |         0 |            0 |          0 |          0 | 117 MB
 perf        | payments                |         0 |         0 |         0 |            0 |          0 |          0 | 83 MB
 perf        | app_events              |         0 |         0 |         0 |            0 |          0 |          0 | 95 MB
 public      | demo_users              |         0 |         0 |         0 |            0 |          0 |          0 | 4400 kB
 perf        | inventory               |         0 |         0 |         0 |            0 |          0 |          0 | 3416 kB
```

### 19_dml_optimization/02_hot_update_efficiency.sql
- Status: PASS
- Exit code: 0
- Output file: out/19_dml_optimization/02_hot_update_efficiency.out.txt

```text
 schema_name | table_name | n_tup_upd | n_tup_hot_upd | hot_update_pct | total_size 
-------------+------------+-----------+---------------+----------------+------------
(0 rows)

```

### 19_dml_optimization/03_missing_fk_supporting_indexes.sql
- Status: PASS
- Exit code: 0
- Output file: out/19_dml_optimization/03_missing_fk_supporting_indexes.out.txt

```text
 schema_name |     table_name     |          foreign_key_name           | fk_columns_attnums 
-------------+--------------------+-------------------------------------+--------------------
 perf        | addresses          | addresses_user_id_fkey              | {3}
 perf        | categories         | categories_tenant_id_fkey           | {2}
 perf        | job_runs           | job_runs_job_id_fkey                | {3}
 perf        | notifications      | notifications_user_id_fkey          | {3}
 perf        | order_items        | order_items_product_id_fkey         | {4}
 perf        | orders             | orders_tenant_id_fkey               | {2}
 perf        | product_categories | product_categories_category_id_fkey | {3}
 perf        | products           | products_tenant_id_fkey             | {2}
 perf        | sessions           | sessions_user_id_fkey               | {3}
 perf        | shipments          | shipments_order_id_fkey             | {3}
 perf        | support_tickets    | support_tickets_user_id_fkey        | {3}
 perf        | ticket_comments    | ticket_comments_ticket_id_fkey      | {3}
 perf        | users              | users_tenant_id_fkey                | {2}
(13 rows)

```

### 19_dml_optimization/04_dml_bloat_pressure.sql
- Status: PASS
- Exit code: 0
- Output file: out/19_dml_optimization/04_dml_bloat_pressure.out.txt

```text
 schema_name | table_name | n_live_tup | n_dead_tup | dead_tuple_pct | total_writes | total_size 
-------------+------------+------------+------------+----------------+--------------+------------
(0 rows)

```

### 20_design_matters/01_tables_without_primary_keys.sql
- Status: PASS
- Exit code: 0
- Output file: out/20_design_matters/01_tables_without_primary_keys.out.txt

```text
 schema_name |       table_name        | total_size 
-------------+-------------------------+------------
 dba_metrics | table_size_snapshots    | 48 kB
 dba_metrics | index_size_snapshots    | 48 kB
 dba_metrics | connection_snapshots    | 16 kB
 dba_metrics | database_size_snapshots | 16 kB
 dba_metrics | wal_snapshots           | 16 kB
(5 rows)

```

### 20_design_matters/02_wide_tables_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/20_design_matters/02_wide_tables_profile.out.txt

```text
 schema_name |       table_name        | column_count | estimated_live_rows | total_size 
-------------+-------------------------+--------------+---------------------+------------
 perf        | audit_log               |            8 |                   0 | 24 kB
 perf        | payments                |            7 |                   0 | 83 MB
 perf        | addresses               |            7 |                   0 | 1576 kB
 perf        | job_runs                |            7 |                   0 | 16 kB
 perf        | order_items             |            6 |                   0 | 117 MB
 perf        | app_events              |            6 |                   0 | 95 MB
 perf        | orders                  |            6 |                   0 | 75 MB
 perf        | shipments               |            6 |                   0 | 18 MB
 dba_metrics | index_size_snapshots    |            6 |                 136 | 48 kB
 dba_metrics | table_size_snapshots    |            6 |                 108 | 48 kB
 perf        | documents               |            6 |                   0 | 24 kB
 perf        | ticket_comments         |            6 |                   0 | 16 kB
 perf        | notifications           |            6 |                   0 | 16 kB
 dba_metrics | connection_snapshots    |            6 |                  20 | 16 kB
 perf        | jobs                    |            6 |                   0 | 16 kB
 perf        | support_tickets         |            6 |                   0 | 16 kB
 perf        | users                   |            5 |                   0 | 4720 kB
 perf        | products                |            5 |                   0 | 2232 kB
```

### 20_design_matters/03_overindexed_tables.sql
- Status: PASS
- Exit code: 0
- Output file: out/20_design_matters/03_overindexed_tables.out.txt

```text
 schema_name |       table_name        | index_count | total_writes | total_size 
-------------+-------------------------+-------------+--------------+------------
 public      | demo_users              |           4 |            0 | 4400 kB
 perf        | orders                  |           3 |            0 | 75 MB
 perf        | app_events              |           3 |            0 | 95 MB
 perf        | users                   |           2 |            0 | 4720 kB
 perf        | audit_log               |           2 |            0 | 24 kB
 perf        | payments                |           2 |            0 | 83 MB
 perf        | order_items             |           2 |            0 | 117 MB
 perf        | documents               |           2 |            0 | 24 kB
 perf        | job_runs                |           1 |            0 | 16 kB
 perf        | shipments               |           1 |            0 | 18 MB
 perf        | categories              |           1 |            0 | 96 kB
 perf        | support_tickets         |           1 |            0 | 16 kB
 perf        | inventory               |           1 |            0 | 3416 kB
 perf        | tenants                 |           1 |            0 | 32 kB
 perf        | feature_flags           |           1 |            0 | 120 kB
 perf        | product_categories      |           1 |            0 | 2640 kB
 perf        | addresses               |           1 |            0 | 1576 kB
 perf        | jobs                    |           1 |            0 | 16 kB
```

### 20_design_matters/04_high_nullability_columns.sql
- Status: PASS
- Exit code: 0
- Output file: out/20_design_matters/04_high_nullability_columns.out.txt

```text
 schema_name | table_name | column_name | null_frac | n_distinct | correlation 
-------------+------------+-------------+-----------+------------+-------------
(0 rows)

```

### 21_configuration_parameters/01_core_performance_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/21_configuration_parameters/01_core_performance_settings.out.txt

```text
              name               | setting | unit |       source       | boot_val | reset_val 
---------------------------------+---------+------+--------------------+----------+-----------
 effective_cache_size            | 524288  | 8kB  | default            | 524288   | 524288
 effective_io_concurrency        | 16      |      | default            | 16       | 16
 maintenance_work_mem            | 65536   | kB   | default            | 65536    | 65536
 max_parallel_workers            | 8       |      | default            | 8        | 8
 max_parallel_workers_per_gather | 2       |      | default            | 2        | 2
 max_worker_processes            | 8       |      | default            | 8        | 8
 shared_buffers                  | 16384   | 8kB  | configuration file | 16384    | 16384
 work_mem                        | 4096    | kB   | default            | 4096     | 4096
(8 rows)

```

### 21_configuration_parameters/02_wal_checkpoint_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/21_configuration_parameters/02_wal_checkpoint_settings.out.txt

```text
             name             | setting | unit |       source       
------------------------------+---------+------+--------------------
 checkpoint_completion_target | 0.9     |      | default
 checkpoint_timeout           | 300     | s    | default
 max_wal_size                 | 1024    | MB   | configuration file
 min_wal_size                 | 80      | MB   | configuration file
 synchronous_commit           | on      |      | default
 wal_buffers                  | 512     | 8kB  | default
 wal_compression              | off     |      | default
 wal_level                    | replica |      | default
 wal_writer_delay             | 200     | ms   | default
 wal_writer_flush_after       | 128     | 8kB  | default
(10 rows)

```

### 21_configuration_parameters/03_autovacuum_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/21_configuration_parameters/03_autovacuum_settings.out.txt

```text
              name               |  setting  | unit | source  
---------------------------------+-----------+------+---------
 autovacuum                      | on        |      | default
 autovacuum_analyze_scale_factor | 0.1       |      | default
 autovacuum_analyze_threshold    | 50        |      | default
 autovacuum_freeze_max_age       | 200000000 |      | default
 autovacuum_max_workers          | 3         |      | default
 autovacuum_naptime              | 60        | s    | default
 autovacuum_vacuum_scale_factor  | 0.2       |      | default
 autovacuum_vacuum_threshold     | 50        |      | default
 vacuum_freeze_min_age           | 50000000  |      | default
 vacuum_freeze_table_age         | 150000000 |      | default
(10 rows)

```

### 21_configuration_parameters/04_connection_timeout_settings.sql
- Status: PASS
- Exit code: 0
- Output file: out/21_configuration_parameters/04_connection_timeout_settings.out.txt

```text
                name                 | setting | unit |       source       
-------------------------------------+---------+------+--------------------
 idle_in_transaction_session_timeout | 0       | ms   | default
 lock_timeout                        | 0       | ms   | default
 max_connections                     | 100     |      | configuration file
 statement_timeout                   | 0       | ms   | default
 superuser_reserved_connections      | 3       |      | default
 tcp_keepalives_count                | 0       |      | default
 tcp_keepalives_idle                 | 0       | s    | default
 tcp_keepalives_interval             | 0       | s    | default
(8 rows)

```

### 22_application_orm_performance/01_n_plus_one_query_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/22_application_orm_performance/01_n_plus_one_query_candidates.out.txt

```text
       queryid        |  calls  |     mean_exec_time     |   total_exec_time    |  rows   |    recommendation    |                                                                                                                  query_snippet                                                                                                                   
----------------------+---------+------------------------+----------------------+---------+----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  3387776431457662738 | 5332823 |   0.020229971087544072 |   107882.85510483896 | 5332823 | Strong N+1 candidate | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
  1144016440436625022 | 5332823 |     3.8100014295381928 |   20318063.253471453 | 5332823 | Strong N+1 candidate | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
  4854991825702068830 | 5332823 | 0.00011239772255708013 |     599.397160031148 |       0 | Strong N+1 candidate | BEGIN
  6097083398544187049 | 5332823 | 0.00011446138958671586 |    610.4023310318215 |       0 | Strong N+1 candidate | END
 -1078345578982625442 | 5332823 |   0.006840656719152106 |    36480.01148695377 | 5332823 | Strong N+1 candidate | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  -305747636952590102 | 5332823 |   0.039258094757131864 |   209356.47065673055 | 5332823 | Strong N+1 candidate | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
 -5371882943115234533 | 5332823 |    0.08268383982104996 |    440938.2827256841 | 5332823 | Strong N+1 candidate | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  3481893718825960883 |    7109 |     2.8211766362357635 |    20055.74470699987 |   35545 | Observe              | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                +
                      |         |                        |                      |         |                      | FROM (SELECT                                                                                                                                                                                                                                    +
                      |         |                        |                      |         |                      |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                   +
                      |         |                        |                      |         |                      |    (SELECT count(*) 
  6967984576543786987 |    1310 |  0.0017542320610687042 |   2.2980440000000093 |    1940 | Observe              | SELECT * FROM pg_catalog.unnest($1) WITH ORDINALITY
 -6043488156747258108 |      64 |   0.019471999999999996 |   1.2462079999999995 |      64 | Observe              | SELECT                                                                                                                                                                                                                                          +
                      |         |                        |                      |         |                      |     db.oid as did, db.datname, db.datallowconn,                                                                                                                                                                                                 +
                      |         |                        |                      |         |                      |     pg_encoding_to_char(db.encoding) AS serverencoding,                                                                                                                                                                                         +
                      |         |                        |                      |         |                      |     has_database_privilege(db.oid, $1) as cancreate,                                                                                                                                                                                            +
                      |         |                        |                      |         |                      |     datistemplate                                                                                                                                                                                                                               +
                      |         |                        |                      |         |                      | FROM                                                                                                                                                                                                                                            +
```

### 22_application_orm_performance/02_select_star_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/22_application_orm_performance/02_select_star_candidates.out.txt

```text
       queryid        | calls |   total_exec_time    |    mean_exec_time     | rows |                                                                                                                                                query_snippet                                                                                                                                                 
----------------------+-------+----------------------+-----------------------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -7038069733341480218 |     1 |   17.545082999999998 |    17.545082999999998 | 2185 | SELECT * FROM (SELECT current_database() AS current_database, n.nspname,c.relname,a.attname,a.atttypid,a.attnotnull  OR (t.typtype = $1 AND t.typnotnull) AS attnotnull,a.atttypmod,a.attlen,t.typtypmod,row_number() OVER (PARTITION BY a.attrelid ORDER BY a.attnum) AS attnum, nullif(a.attidentity, $2) 
  6967984576543786987 |  1310 |   2.2980440000000093 | 0.0017542320610687042 | 1940 | SELECT * FROM pg_catalog.unnest($1) WITH ORDINALITY
   515528283152159450 |     2 | 0.018583999999999996 |  0.009291999999999998 |    2 | SELECT * FROM pg_catalog.pg_rewrite WHERE ev_class = $1 AND rulename = $2
(3 rows)

```

### 22_application_orm_performance/03_chatty_small_result_queries.sql
- Status: PASS
- Exit code: 0
- Output file: out/22_application_orm_performance/03_chatty_small_result_queries.out.txt

```text
       queryid        |  calls  |  rows   | avg_rows_per_call |     mean_exec_time     |  total_exec_time   |                                                                 query_snippet                                                                 
----------------------+---------+---------+-------------------+------------------------+--------------------+-----------------------------------------------------------------------------------------------------------------------------------------------
  6097083398544187049 | 5332823 |       0 |            0.0000 | 0.00011446138958671586 |  610.4023310318215 | END
  4854991825702068830 | 5332823 |       0 |            0.0000 | 0.00011239772255708013 |   599.397160031148 | BEGIN
  -305747636952590102 | 5332823 | 5332823 |            1.0000 |   0.039258094757131864 | 209356.47065673055 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 | 5332823 |            1.0000 |   0.020229971087544072 | 107882.85510483896 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
  1144016440436625022 | 5332823 | 5332823 |            1.0000 |     3.8100014295381928 | 20318063.253471453 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 | 5332823 |            1.0000 |    0.08268383982104996 |  440938.2827256841 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
 -1078345578982625442 | 5332823 | 5332823 |            1.0000 |   0.006840656719152106 |  36480.01148695377 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |   35545 |            5.0000 |     2.8211766362357635 |  20055.74470699987 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                             +
                      |         |         |                   |                        |                    | FROM (SELECT                                                                                                                                 +
                      |         |         |                   |                        |                    |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",+
                      |         |         |                   |                        |                    |    (SELECT count(*) FROM pg_catalog.pg_s
(8 rows)

```

### 22_application_orm_performance/04_app_idle_in_transaction_risk.sql
- Status: PASS
- Exit code: 0
- Output file: out/22_application_orm_performance/04_app_idle_in_transaction_risk.out.txt

```text
 application_name | user_name | database_name | idle_in_txn_sessions | oldest_xact_start | max_xact_age 
------------------+-----------+---------------+----------------------+-------------------+--------------
(0 rows)

```

### 23_functions_dynamic_sql/01_function_execution_hotspots.sql
- Status: PASS
- Exit code: 0
- Output file: out/23_functions_dynamic_sql/01_function_execution_hotspots.out.txt

```text
 schema_name | function_name | calls | total_time | self_time | mean_time 
-------------+---------------+-------+------------+-----------+-----------
(0 rows)

```

### 23_functions_dynamic_sql/02_dynamic_sql_function_inventory.sql
- Status: PASS
- Exit code: 0
- Output file: out/23_functions_dynamic_sql/02_dynamic_sql_function_inventory.out.txt

```text
 schema_name | function_name | function_args | language_name | security_definer | has_dynamic_sql 
-------------+---------------+---------------+---------------+------------------+-----------------
(0 rows)

```

### 23_functions_dynamic_sql/03_volatile_and_security_definer_functions.sql
- Status: PASS
- Exit code: 0
- Output file: out/23_functions_dynamic_sql/03_volatile_and_security_definer_functions.out.txt

```text
 schema_name |      function_name       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            function_args                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | provolatile | security_definer | language_name 
-------------+--------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+------------------+---------------
 public      | pg_stat_statements       | showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT wal_buffers_full bigint, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT parallel_workers_to_launch bigint, OUT parallel_workers_launched bigint, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone | v           | f                | c
 public      | pg_stat_statements_info  | OUT dealloc bigint, OUT stats_reset timestamp with time zone                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | v           | f                | c
 public      | pg_stat_statements_reset | userid oid, dbid oid, queryid bigint, minmax_only boolean                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | v           | f                | c
(3 rows)

```

### 23_functions_dynamic_sql/04_trigger_function_inventory.sql
- Status: PASS
- Exit code: 0
- Output file: out/23_functions_dynamic_sql/04_trigger_function_inventory.out.txt

```text
 table_schema | table_name | trigger_name | function_schema | function_name | tgenabled | trigger_def 
--------------+------------+--------------+-----------------+---------------+-----------+-------------
(0 rows)

```

### 24_complex_filter_search/01_like_ilike_query_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/24_complex_filter_search/01_like_ilike_query_candidates.out.txt

```text
       queryid        | calls |   total_exec_time   |   mean_exec_time    | shared_blks_read | temp_blks_written |                                                                                                                                                          query_snippet                                                                                                                                                           
----------------------+-------+---------------------+---------------------+------------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  7590930821846221194 |     3 |  21.081459000000002 |   7.027153000000002 |                1 |                 0 | SELECT                                                                                                                                                                                                                                                                                                                          +
                      |       |                     |                     |                  |                   |     n.nspname AS schema_name,                                                                                                                                                                                                                                                                                                   +
                      |       |                     |                     |                  |                   |     c.relname AS table_name,                                                                                                                                                                                                                                                                                                    +
                      |       |                     |                     |                  |                   |     a.attname AS column_name,                                                                                                                                                                                                                                                                                                   +
                      |       |                     |                     |                  |                   |     pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type                                                                                                                                                                                                                                                                +
                      |       |                     |                     |                  |                   | FROM pg_attribute a                                                                                                                                                                                                                                                                                                             +
                      |       |                     |                     |                  |                   | JOIN pg_class c                                                                                                                                                                                                                                                                                                                 +
                      |       |                     |                     |                  |                   |     ON c.oid = a.attrelid                                                                                                                                                                                                                                                                                                       +
                      |       |                     |                     |                  |                   | JOIN pg_namespace n                                                                                                                                                                                                                                                                                                             +
                      |       |                     |                     |                  |                   |     ON n.oid = c.relnamespace                                                                                                                                                                                                                                                                                                   +
                      |       |                     |                     |                  |                   | WHERE c.relkind = $1                                                                                                                                                                                                                                                                                                            +
                      |       |                     |                     |                  |                   |   AND a.attnum > $2                                                                                                                                                                                                                                                                                                             +
                      |       |                     |                     |                  |                   |   AND 
 -7038069733341480218 |     1 |  17.545082999999998 |  17.545082999999998 |               63 |                 0 | SELECT * FROM (SELECT current_database() AS current_database, n.nspname,c.relname,a.attname,a.atttypid,a.attnotnull  OR (t.typtype = $1 AND t.typnotnull) AS attnotnull,a.atttypmod,a.attlen,t.typtypmod,row_number() OVER (PARTITION BY a.attrelid ORDER BY a.attnum) AS attnum, nullif(a.attidentity, $2) as attidentity,nulli
  8372816081463946943 |     1 |            13.47625 |            13.47625 |               24 |                 0 | WITH                                                                                                                                                                                                                                                                                                                            +
                      |       |                     |                     |                  |                   | params AS (                                                                                                                                                                                                                                                                                                                     +
                      |       |                     |                     |                  |                   |   SELECT                                                                                                                                                                                                                                                                                                                        +
                      |       |                     |                     |                  |                   |     $1::text AS report_title,                                                                                                                                                                                                                                                                                                   +
```

### 24_complex_filter_search/02_jsonb_array_column_inventory.sql
- Status: PASS
- Exit code: 0
- Output file: out/24_complex_filter_search/02_jsonb_array_column_inventory.out.txt

```text
 schema_name |  table_name   | column_name | data_type 
-------------+---------------+-------------+-----------
 perf        | app_events    | payload     | jsonb
 perf        | audit_log     | details     | jsonb
 perf        | job_runs      | metrics     | jsonb
 perf        | jobs          | meta        | jsonb
 perf        | notifications | payload     | jsonb
(5 rows)

```

### 24_complex_filter_search/03_gin_gist_brin_index_inventory.sql
- Status: PASS
- Exit code: 0
- Output file: out/24_complex_filter_search/03_gin_gist_brin_index_inventory.out.txt

```text
 schema_name | table_name | index_name | access_method | index_size 
-------------+------------+------------+---------------+------------
(0 rows)

```

### 24_complex_filter_search/04_full_text_search_inventory.sql
- Status: PASS
- Exit code: 0
- Output file: out/24_complex_filter_search/04_full_text_search_inventory.out.txt

```text
 schema_name | table_name | column_name | data_type 
-------------+------------+-------------+-----------
(0 rows)

```

### 25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.sql
- Status: PASS
- Exit code: 0
- Output file: out/25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.out.txt

```text
       queryid        |  calls  |     mean_exec_time     |       rows_per_call        | shared_blks_read | temp_blks_written | workload_class |                                                                                                                            query_snippet                                                                                                                             
----------------------+---------+------------------------+----------------------------+------------------+-------------------+----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |     3.8100014295381928 |     1.00000000000000000000 |         10664795 |                 0 | OLTP-like      | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |    0.08268383982104996 |     1.00000000000000000000 |             1205 |                 0 | OLTP-like      | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 |   0.039258094757131864 |     1.00000000000000000000 |             1533 |                 0 | OLTP-like      | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 |   0.020229971087544072 |     1.00000000000000000000 |            19313 |                 0 | OLTP-like      | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |   0.006840656719152106 |     1.00000000000000000000 |               55 |                 0 | OLTP-like      | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |     2.8211766362357635 |         5.0000000000000000 |               97 |                 0 | OLTP-like      | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                    +
                      |         |                        |                            |                  |                   |                | FROM (SELECT                                                                                                                                                                                                                                                        +
                      |         |                        |                            |                  |                   |                |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                       +
                      |         |                        |                            |                  |                   |                |    (SELECT count(*) FROM pg_catalog.pg_s
   450201137788272562 |       1 |            1674.504167 |     0.00000000000000000000 |            29989 |                 0 | OLAP-like      | ANALYZE
 -5398677000037045473 |       1 |             802.498625 |     0.00000000000000000000 |            53105 |                 0 | OLAP-like      | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
  6097083398544187049 | 5332823 | 0.00011446138958671586 | 0.000000000000000000000000 |                0 |                 0 | OLTP-like      | END
  4854991825702068830 | 5332823 | 0.00011239772255708013 | 0.000000000000000000000000 |                0 |                 0 | OLTP-like      | BEGIN
  4640742184386830055 |      63 |     2.4680925555555544 |     1.00000000000000000000 |                8 |                 0 | Mixed          | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  8710856124765966157 |       4 |              33.389406 |       337.0000000000000000 |               48 |                 0 | Mixed          | SELECT                                                                                                                                                                                                                                                              +
                      |         |                        |                            |                  |                   |                |     n.nspname AS schema_name,                                                                                                                                                                                                                                       +
                      |         |                        |                            |                  |                   |                |     c.relname AS catalog_name,                                                                                                                                                                                                                                      +
                      |         |                        |                            |                  |                   |                |     c.relkind,                                                                                                                                                                                                                                                      +
```

### 25_oltp_olap_goals/02_oltp_latency_goal_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/25_oltp_olap_goals/02_oltp_latency_goal_candidates.out.txt

```text
 queryid | calls | mean_exec_time | total_exec_time | rows | shared_blks_read | temp_blks_written | query_snippet 
---------+-------+----------------+-----------------+------+------------------+-------------------+---------------
(0 rows)

```

### 25_oltp_olap_goals/03_olap_throughput_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/25_oltp_olap_goals/03_olap_throughput_candidates.out.txt

```text
       queryid        |  calls  |  total_exec_time   |   mean_exec_time   | shared_blks_read | temp_blks_written |  rows   |                            query_snippet                             
----------------------+---------+--------------------+--------------------+------------------+-------------------+---------+----------------------------------------------------------------------
  1144016440436625022 | 5332823 | 20318063.253471453 | 3.8100014295381928 |         10664795 |                 0 | 5332823 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
   450201137788272562 |       1 |        1674.504167 |        1674.504167 |            29989 |                 0 |       0 | ANALYZE
 -5398677000037045473 |       1 |         802.498625 |         802.498625 |            53105 |                 0 |       0 | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
(3 rows)

```

### 25_oltp_olap_goals/04_mixed_workload_pressure.sql
- Status: PASS
- Exit code: 0
- Output file: out/25_oltp_olap_goals/04_mixed_workload_pressure.out.txt

```text
           database_name           | xact_commit | xact_rollback | blks_read | blks_hit  | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | numbackends | recommendation 
-----------------------------------+-------------+---------------+-----------+-----------+------------+------------+-----------+---------------+----------------+-------------+----------------
 pgbench_test                      |     5349080 |             2 |  14208247 | 141642704 |          6 | 4008443904 |         0 |             0 |              0 |           0 | Normal/Mild
 hypopg_lab                        |        8351 |             0 |      4016 |    317959 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
 appdb                             |        9030 |             9 |      1541 |    326701 |          0 |          0 |         0 |             0 |              0 |           2 | Normal/Mild
 postgres                          |        8929 |             8 |      1476 |    387431 |          0 |          0 |         0 |             0 |              0 |           2 | Normal/Mild
 perf_test                         |        8361 |             2 |      1103 |    316753 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
 script_validation_20260218_172749 |        1145 |            24 |       296 |    530760 |          0 |          0 |         0 |             0 |              0 |           1 | Normal/Mild
(6 rows)

```

### 26_physical_cloud_diagnostics/01_instance_platform_fingerprint.sql
- Status: PASS
- Exit code: 0
- Output file: out/26_physical_cloud_diagnostics/01_instance_platform_fingerprint.out.txt

```text
                                                        version_string                                                        | server_version_num |         data_directory          |                   config_file                   |                  hba_file                   |     postmaster_start_time     |         uptime         |              platform_hint              
------------------------------------------------------------------------------------------------------------------------------+--------------------+---------------------------------+-------------------------------------------------+---------------------------------------------+-------------------------------+------------------------+-----------------------------------------
 PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit | 180000             | /opt/homebrew/var/postgresql@18 | /opt/homebrew/var/postgresql@18/postgresql.conf | /opt/homebrew/var/postgresql@18/pg_hba.conf | 2026-02-10 09:32:09.191307-05 | 8 days 08:04:05.350693 | Self-managed or unknown managed service
(1 row)

```

### 26_physical_cloud_diagnostics/02_io_latency_profile.sql
- Status: PASS
- Exit code: 0
- Output file: out/26_physical_cloud_diagnostics/02_io_latency_profile.out.txt

```text
           database_name           | blks_read | blks_hit  | blk_read_time | blk_write_time | ms_per_block_read | write_time_per_txn 
-----------------------------------+-----------+-----------+---------------+----------------+-------------------+--------------------
 postgres                          |      1476 |    387431 |             0 |              0 |                 0 |                  0
 perf_test                         |      1103 |    316753 |             0 |              0 |                 0 |                  0
 appdb                             |      1541 |    326701 |             0 |              0 |                 0 |                  0
 hypopg_lab                        |      4016 |    317959 |             0 |              0 |                 0 |                  0
 pgbench_test                      |  14208247 | 141642704 |             0 |              0 |                 0 |                  0
 script_validation_20260218_172749 |       296 |    531281 |             0 |              0 |                 0 |                  0
(6 rows)

```

### 26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql
- Status: PASS
- Exit code: 0
- Output file: out/26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.out.txt

```text
 checkpoints_timed | checkpoints_req | checkpoint_write_time | checkpoint_sync_time | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_alloc |      recommendation       |   checkpointer_stats_reset    |     bgwriter_stats_reset      
-------------------+-----------------+-----------------------+----------------------+--------------------+--------------+---------------+------------------+---------------+---------------------------+-------------------------------+-------------------------------
               826 |              59 |               2788826 |                48655 |              27276 |          210 |        244345 |             2422 |      10825268 | Normal checkpoint profile | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
(1 row)

```

### 26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.sql
- Status: PASS
- Exit code: 0
- Output file: out/26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.out.txt

```text
 slot_name | slot_type | active | temporary | restart_lsn | confirmed_flush_lsn | retained_wal_bytes | retained_wal_pretty | wal_status | safe_wal_size 
-----------+-----------+--------+-----------+-------------+---------------------+--------------------+---------------------+------------+---------------
(0 rows)

```

### 27_high_speed_tuning/01_bottleneck_overview_dashboard.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/01_bottleneck_overview_dashboard.out.txt

```text
 total_connections | active_connections | idle_in_txn_connections | waiting_sessions | waiting_locks | granted_locks | deadlocks | blks_read | blks_hit  | cache_hit_pct | temp_files | temp_bytes | temp_bytes_pretty | blk_read_time | blk_write_time | checkpoints_timed | checkpoints_req | requested_checkpoint_pct | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_alloc | checkpoint_write_time | checkpoint_sync_time |   checkpointer_stats_reset    |     bgwriter_stats_reset      |         top_bottleneck_hint         
-------------------+--------------------+-------------------------+------------------+---------------+---------------+-----------+-----------+-----------+---------------+------------+------------+-------------------+---------------+----------------+-------------------+-----------------+--------------------------+--------------------+--------------+---------------+------------------+---------------+-----------------------+----------------------+-------------------------------+-------------------------------+-------------------------------------
                13 |                  1 |                       0 |               12 |             0 |            12 |         0 |  14216679 | 143523884 |         90.99 |          6 | 4008443904 | 3823 MB           |             0 |              0 |               826 |              59 |                     6.67 |              27276 |          210 |        244345 |             2422 |      10825268 |               2788826 |                48655 | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05 | No dominant global bottleneck found
(1 row)

```

### 27_high_speed_tuning/02_waits_and_blocking_details.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/02_waits_and_blocking_details.out.txt

```text
 blocked_pid | blocked_user | blocked_app | blocked_database | blocked_query_age | blocked_query | blocker_pid | blocker_user | blocker_app | blocker_state | blocker_query_age | blocker_query | blocker_wait_type | blocker_wait_event 
-------------+--------------+-------------+------------------+-------------------+---------------+-------------+--------------+-------------+---------------+-------------------+---------------+-------------------+--------------------
(0 rows)

```

### 27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.out.txt

```text
 schema_name | table_name | total_bytes | total_pretty | estimated_live_rows | seq_scan | idx_scan | seq_scan_pct | heap_blks_read | heap_blks_hit | recommendation | index_template 
-------------+------------+-------------+--------------+---------------------+----------+----------+--------------+----------------+---------------+----------------+----------------
(0 rows)

```

### 27_high_speed_tuning/04_missing_fk_index_candidates.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/04_missing_fk_index_candidates.out.txt

```text
 schema_name |     table_name     |          foreign_key_name           | fk_columns  |                                                      suggested_index_sql                                                       
-------------+--------------------+-------------------------------------+-------------+--------------------------------------------------------------------------------------------------------------------------------
 perf        | addresses          | addresses_user_id_fkey              | user_id     | CREATE INDEX CONCURRENTLY idx_addresses_addresses_user_id_fkey ON perf.addresses (user_id);
 perf        | categories         | categories_tenant_id_fkey           | tenant_id   | CREATE INDEX CONCURRENTLY idx_categories_categories_tenant_id_fkey ON perf.categories (tenant_id);
 perf        | job_runs           | job_runs_job_id_fkey                | job_id      | CREATE INDEX CONCURRENTLY idx_job_runs_job_runs_job_id_fkey ON perf.job_runs (job_id);
 perf        | notifications      | notifications_user_id_fkey          | user_id     | CREATE INDEX CONCURRENTLY idx_notifications_notifications_user_id_fkey ON perf.notifications (user_id);
 perf        | order_items        | order_items_product_id_fkey         | product_id  | CREATE INDEX CONCURRENTLY idx_order_items_order_items_product_id_fkey ON perf.order_items (product_id);
 perf        | orders             | orders_tenant_id_fkey               | tenant_id   | CREATE INDEX CONCURRENTLY idx_orders_orders_tenant_id_fkey ON perf.orders (tenant_id);
 perf        | product_categories | product_categories_category_id_fkey | category_id | CREATE INDEX CONCURRENTLY idx_product_categories_product_categories_category_id_fkey ON perf.product_categories (category_id);
 perf        | products           | products_tenant_id_fkey             | tenant_id   | CREATE INDEX CONCURRENTLY idx_products_products_tenant_id_fkey ON perf.products (tenant_id);
 perf        | sessions           | sessions_user_id_fkey               | user_id     | CREATE INDEX CONCURRENTLY idx_sessions_sessions_user_id_fkey ON perf.sessions (user_id);
 perf        | shipments          | shipments_order_id_fkey             | order_id    | CREATE INDEX CONCURRENTLY idx_shipments_shipments_order_id_fkey ON perf.shipments (order_id);
 perf        | support_tickets    | support_tickets_user_id_fkey        | user_id     | CREATE INDEX CONCURRENTLY idx_support_tickets_support_tickets_user_id_fkey ON perf.support_tickets (user_id);
 perf        | ticket_comments    | ticket_comments_ticket_id_fkey      | ticket_id   | CREATE INDEX CONCURRENTLY idx_ticket_comments_ticket_comments_ticket_id_fkey ON perf.ticket_comments (ticket_id);
 perf        | users              | users_tenant_id_fkey                | tenant_id   | CREATE INDEX CONCURRENTLY idx_users_users_tenant_id_fkey ON perf.users (tenant_id);
(13 rows)

```

### 27_high_speed_tuning/05_parameter_tuning_advisor.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/05_parameter_tuning_advisor.out.txt

```text
          parameter           |            current_value             | severity |                                      finding                                      |                                       recommendation                                        
------------------------------+--------------------------------------+----------+-----------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------
 shared_buffers               | 160 MB                               | high     | Low shared_buffers can increase physical reads.                                   | For dedicated DB hosts, start around 15-30% of RAM and validate with cache hit and latency.
 max_wal_size                 | 1024 MB                              | medium   | Low max_wal_size can force frequent checkpoints and write pressure.               | Increase max_wal_size and review checkpoint metrics.
 random_page_cost             | 4                                    | medium   | High random_page_cost may discourage useful index scans on SSD/cloud storage.     | Benchmark lower values (for example 1.1-2.0) in staging before production.
 track_io_timing              | off                                  | medium   | Without I/O timing, root-cause analysis of storage bottlenecks is limited.        | Enable track_io_timing for better performance diagnostics.
 work_mem                     | 4096 kB                              | medium   | Low work_mem increases sort/hash spill risk (temp files).                         | Increase carefully per workload; remember it is per operation, per backend.
 autovacuum                   | on                                   | ok       | Autovacuum is required to control bloat and transaction age.                      | Keep autovacuum enabled and tune thresholds/scales by table size and write rate.
 checkpoint_completion_target | 0.9                                  | ok       | Low target can create bursty checkpoint I/O.                                      | Use around 0.7-0.9 for smoother write profile.
 effective_cache_size         | 5120 MB                              | ok       | Too-low effective_cache_size can bias planner away from index plans.              | Set roughly to OS cache + shared_buffers visible to PostgreSQL.
 jit                          | on                                   | ok       | JIT may help CPU-heavy long queries but can hurt very short OLTP queries.         | Evaluate JIT effect by workload class (OLTP vs OLAP).
 max_connections              | 100                                  | ok       | Too many direct connections can reduce throughput and increase context switching. | Use a connection pool; target lower active backend count for OLTP.
 parallel_workers             | max_parallel_workers=8, per_gather=2 | ok       | No parallel workers can slow analytical scans and aggregations.                   | Enable and tune parallel workers for OLAP/reporting workloads.
(11 rows)

```

### 27_high_speed_tuning/06_query_tuning_action_queue.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_high_speed_tuning/06_query_tuning_action_queue.out.txt

```text
       queryid        |  calls  |   total_exec_time    |     mean_exec_time     |    stddev_exec_time    |  rows   | shared_blks_hit | shared_blks_read | temp_blks_written |     root_cause_hint      |                 recommended_next_action                 |                                                                                                                                                                         query_snippet                                                                                                                                                                          
----------------------+---------+----------------------+------------------------+------------------------+---------+-----------------+------------------+-------------------+--------------------------+---------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |   20318063.253471453 |     3.8100014295381928 |      92.32002420399405 | 5332823 |        45639018 |         10664795 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |    440938.2827256841 |    0.08268383982104996 |     2.0963843383810876 | 5332823 |        30081894 |             1205 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 |   209356.47065673055 |   0.039258094757131864 |      0.625514976433878 | 5332823 |        27087536 |             1533 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 |   107882.85510483896 |   0.020229971087544072 |     2.4970450599666827 | 5332823 |         5534382 |            19313 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |    36480.01148695377 |   0.006840656719152106 |    0.05010911945496172 | 5332823 |        29324806 |               55 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |    20055.74470699987 |     2.8211766362357635 |     117.82179113781538 |   35545 |          216589 |               97 |                 0 | Unstable runtime/plan    | Check parameter-sensitive plans and stale statistics.   | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                                                                                              +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         | FROM (SELECT                                                                                                                                                                                                                                                                                                                                                  +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                                                                                                 +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WH
   450201137788272562 |       1 |          1674.504167 |            1674.504167 |                      0 |       0 |            9664 |            29989 |                 0 | I/O-bound pattern        | Review missing indexes and cache efficiency.            | ANALYZE
 -5398677000037045473 |       1 |           802.498625 |             802.498625 |                      0 |       0 |             238 |            53105 |                 0 | I/O-bound pattern        | Review missing indexes and cache efficiency.            | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
  6097083398544187049 | 5332823 |    610.4023310318215 | 0.00011446138958671586 |    0.00335278765645261 |       0 |               0 |                0 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | END
  4854991825702068830 | 5332823 |     599.397160031148 | 0.00011239772255708013 |  0.0021783571257651454 |       0 |               0 |                0 |                 0 | Chatty/N+1 pattern       | Batch at application layer or reduce query round-trips. | BEGIN
  4640742184386830055 |      63 |           155.489831 |     2.4680925555555544 |     1.0937281720904906 |      63 |             559 |                8 |                 0 | General tuning candidate | Inspect SQL design, indexes, and configuration context. | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
  8710856124765966157 |       4 |           133.557624 |              33.389406 |     3.8411854852449525 |    1348 |           16860 |               48 |                 0 | General tuning candidate | Inspect SQL design, indexes, and configuration context. | SELECT                                                                                                                                                                                                                                                                                                                                                        +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         |     n.nspname AS schema_name,                                                                                                                                                                                                                                                                                                                                 +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         |     c.relname AS catalog_name,                                                                                                                                                                                                                                                                                                                                +
                      |         |                      |                        |                        |         |                 |                  |                   |                          |                                                         |     c.relkind,                                                                                                                                                                                                                                                                                                                                                +
```

### 27_migration_validation/01_oracle_to_postgres_360_health_report.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_migration_validation/01_oracle_to_postgres_360_health_report.out.txt

```text
Pager usage is off.
Border style is 1.
Output format is html.
Title is "Report Metadata".
Title is "Overall Health Summary".
Title is "360-Degree Check Results".
Title is "Issue Details (Top Objects and Sessions)".
Output format is aligned.
HTML report written to postgres_360_migration_health_report.html
```

### 27_migration_validation/02_seed_v1_test_issues.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_migration_validation/02_seed_v1_test_issues.out.txt

```text
Pager usage is off.
[V1 seed] Recreating migration_v1_lab schema...
psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/27_migration_validation/02_seed_v1_test_issues.sql:17: NOTICE:  schema "migration_v1_lab" does not exist, skipping
DROP SCHEMA
CREATE SCHEMA
[V1 seed] Creating table without primary key...
CREATE TABLE
INSERT 0 10000
[V1 seed] Creating unowned sequence...
CREATE SEQUENCE
 nextval 
---------
       1
       2
       3
       4
       5
       6
       7
       8
```

### 27_migration_validation/03_fix_v1_test_issues.sql
- Status: PASS
- Exit code: 0
- Output file: out/27_migration_validation/03_fix_v1_test_issues.out.txt

```text
Pager usage is off.
[V1 fix] Adding primary key to orders_no_pk...
ALTER TABLE
[V1 fix] Attaching orphan sequence ownership...
ALTER SEQUENCE
[V1 fix] Adding FK supporting index...
CREATE INDEX
[V1 fix] Removing duplicate index...
DROP INDEX
[V1 fix] Normalizing uppercase table name...
ALTER TABLE
[V1 fix] Re-enabling autovacuum and refreshing stats...
ALTER TABLE
ANALYZE
[V1 fix] Cleaning dead tuples from pressure table...
ALTER TABLE
VACUUM
[V1 fix] Fix complete.
```

### 28_pgss_resource_attribution/01_pgss_query_resource_percent.sql
- Status: PASS
- Exit code: 0
- Output file: out/28_pgss_resource_attribution/01_pgss_query_resource_percent.out.txt

```text
       queryid        |  calls  |   total_exec_time    |     mean_exec_time     |    cpu_proxy_time    | io_time | temp_bytes_written | temp_pretty | pct_total_exec_time | pct_cpu_proxy_time | pct_io_time | pct_memory_spill | dominant_resource_proxy |                                                                                                                                      query_snippet                                                                                                                                       
----------------------+---------+----------------------+------------------------+----------------------+---------+--------------------+-------------+---------------------+--------------------+-------------+------------------+-------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |   20318063.253471453 |     3.8100014295381928 |   20318063.253471453 |       0 |                  0 | 0 bytes     |               96.11 |              96.11 |             |             0.00 | CPU heavy               | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |    440938.2827256841 |    0.08268383982104996 |    440938.2827256841 |       0 |                  0 | 0 bytes     |                2.09 |               2.09 |             |             0.00 | CPU heavy               | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 |   209356.47065673055 |   0.039258094757131864 |   209356.47065673055 |       0 |                  0 | 0 bytes     |                0.99 |               0.99 |             |             0.00 | CPU heavy               | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 |   107882.85510483896 |   0.020229971087544072 |   107882.85510483896 |       0 |                  0 | 0 bytes     |                0.51 |               0.51 |             |             0.00 | CPU heavy               | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |    36480.01148695377 |   0.006840656719152106 |    36480.01148695377 |       0 |                  0 | 0 bytes     |                0.17 |               0.17 |             |             0.00 | CPU heavy               | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |    20055.74470699987 |     2.8211766362357635 |    20055.74470699987 |       0 |                  0 | 0 bytes     |                0.09 |               0.09 |             |             0.00 | CPU heavy               | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                        +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | FROM (SELECT                                                                                                                                                                                                                                                                            +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                           +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE s
   450201137788272562 |       1 |          1674.504167 |            1674.504167 |          1674.504167 |       0 |                  0 | 0 bytes     |                0.01 |               0.01 |             |             0.00 | CPU heavy               | ANALYZE
 -2373622488710648489 |       4 |  0.47345799999999993 |              0.1183645 |  0.47345799999999993 |       0 |                  0 | 0 bytes     |                0.00 |               0.00 |             |             0.00 | CPU heavy               | INSERT INTO tmp_pg360_issue_details (                                                                                                                                                                                                                                                   +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     check_id,                                                                                                                                                                                                                                                                           +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     object_type,                                                                                                                                                                                                                                                                        +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     object_name,                                                                                                                                                                                                                                                                        +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     metric,                                                                                                                                                                                                                                                                             +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     details,                                                                                                                                                                                                                                                                            +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     recommended_fix                                                                                                                                                                                                                                                                     +
                      |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | )                                                                                                                                                                                                                                                                                       +
```

### 28_pgss_resource_attribution/02_pgss_resource_percent_by_database.sql
- Status: PASS
- Exit code: 0
- Output file: out/28_pgss_resource_attribution/02_pgss_resource_percent_by_database.out.txt

```text
           database_name           |  total_exec_time   |   cpu_proxy_time   | io_time | temp_bytes_written | temp_pretty | pct_exec | pct_cpu_proxy | pct_io | pct_memory_spill 
-----------------------------------+--------------------+--------------------+---------+--------------------+-------------+----------+---------------+--------+------------------
 pgbench_test                      |  21135893.24357873 |  21135893.24357873 |       0 |                  0 | 0 bytes     |    99.98 |         99.98 |        |             0.00
 script_validation_20260218_172749 | 3254.2777090000122 | 3254.2777090000122 |       0 |            1687552 | 1648 kB     |     0.02 |          0.02 |        |           100.00
 postgres                          |        1117.465124 |        1117.465124 |       0 |                  0 | 0 bytes     |     0.01 |          0.01 |        |             0.00
 template1                         |           0.013168 |           0.013168 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
 appdb                             | 26.254455999999994 | 26.254455999999994 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
 perf_test                         |           0.546833 |           0.546833 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
 hypopg_lab                        |          84.404333 |          84.404333 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
(7 rows)

```

### 28_pgss_resource_attribution/03_pgss_resource_percent_by_user.sql
- Status: PASS
- Exit code: 0
- Output file: out/28_pgss_resource_attribution/03_pgss_resource_percent_by_user.out.txt

```text
 user_name |  total_exec_time  |  cpu_proxy_time   | io_time | temp_bytes_written | temp_pretty | pct_exec | pct_cpu_proxy | pct_io | pct_memory_spill 
-----------+-------------------+-------------------+---------+--------------------+-------------+----------+---------------+--------+------------------
 saiendla  | 21119915.68606974 | 21119915.68606974 |       0 |            1687552 | 1648 kB     |    99.90 |         99.90 |        |           100.00
 postgres  | 20461.00471599986 | 20461.00471599986 |       0 |                  0 | 0 bytes     |     0.10 |          0.10 |        |             0.00
(2 rows)

```

### 28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.sql
- Status: PASS
- Exit code: 0
- Output file: out/28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.out.txt

```text
       queryid        |  calls  |   total_exec_time    | pct_exec | pct_cpu_proxy | pct_io | pct_memory_spill |    infra_tier    |                                                                                                                                      query_snippet                                                                                                                                       
----------------------+---------+----------------------+----------+---------------+--------+------------------+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1144016440436625022 | 5332823 |   20318063.253471453 |    96.11 |         96.11 |        |             0.00 | CPU-TIER risk    | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 |    440938.2827256841 |     2.09 |          2.09 |        |             0.00 | LOW-TIER impact  | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
  -305747636952590102 | 5332823 |   209356.47065673055 |     0.99 |          0.99 |        |             0.00 | LOW-TIER impact  | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  3387776431457662738 | 5332823 |   107882.85510483896 |     0.51 |          0.51 |        |             0.00 | LOW-TIER impact  | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
 -1078345578982625442 | 5332823 |    36480.01148695377 |     0.17 |          0.17 |        |             0.00 | LOW-TIER impact  | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3481893718825960883 |    7109 |    20055.74470699987 |     0.09 |          0.09 |        |             0.00 | LOW-TIER impact  | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                        +
                      |         |                      |          |               |        |                  |                  | FROM (SELECT                                                                                                                                                                                                                                                                            +
                      |         |                      |          |               |        |                  |                  |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                           +
                      |         |                      |          |               |        |                  |                  |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE s
   450201137788272562 |       1 |          1674.504167 |     0.01 |          0.01 |        |             0.00 | LOW-TIER impact  | ANALYZE
 -2373622488710648489 |       4 |  0.47345799999999993 |     0.00 |          0.00 |        |             0.00 | LOW-TIER impact  | INSERT INTO tmp_pg360_issue_details (                                                                                                                                                                                                                                                   +
                      |         |                      |          |               |        |                  |                  |     check_id,                                                                                                                                                                                                                                                                           +
                      |         |                      |          |               |        |                  |                  |     object_type,                                                                                                                                                                                                                                                                        +
                      |         |                      |          |               |        |                  |                  |     object_name,                                                                                                                                                                                                                                                                        +
                      |         |                      |          |               |        |                  |                  |     metric,                                                                                                                                                                                                                                                                             +
                      |         |                      |          |               |        |                  |                  |     details,                                                                                                                                                                                                                                                                            +
                      |         |                      |          |               |        |                  |                  |     recommended_fix                                                                                                                                                                                                                                                                     +
                      |         |                      |          |               |        |                  |                  | )                                                                                                                                                                                                                                                                                       +
```

