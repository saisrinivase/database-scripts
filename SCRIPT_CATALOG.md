# PostgreSQL Script Catalog

Purpose: searchable catalog of every SQL script in the postgres branch, with title, purpose, and sample-output coverage.

Total SQL scripts: `232`.

## Area Counts

| Area | Scripts |
| --- | ---: |
| `00_environment` | 3 |
| `01_database_size` | 3 |
| `02_table_storage` | 4 |
| `03_index_analysis` | 4 |
| `04_toast_lob_blob` | 4 |
| `05_partitioning` | 7 |
| `06_activity_locks` | 4 |
| `07_vacuum_bloat` | 5 |
| `08_replication_ha` | 4 |
| `09_security_roles` | 4 |
| `10_maintenance_monitoring` | 5 |
| `11_performance_tuning` | 6 |
| `12_planner_statistics` | 6 |
| `13_io_wal_checkpoints` | 7 |
| `14_connection_workload` | 6 |
| `15_capacity_forecasting` | 8 |
| `16_internals_deep_dive` | 6 |
| `17_execution_plans` | 4 |
| `18_long_queries_full_scans` | 4 |
| `19_dml_optimization` | 4 |
| `20_design_matters` | 4 |
| `21_configuration_parameters` | 4 |
| `22_application_orm_performance` | 4 |
| `23_functions_dynamic_sql` | 4 |
| `24_complex_filter_search` | 4 |
| `25_oltp_olap_goals` | 4 |
| `26_physical_cloud_diagnostics` | 4 |
| `27_high_speed_tuning` | 6 |
| `27_migration_validation` | 9 |
| `28_pgss_resource_attribution` | 4 |
| `29_object_inventory_health` | 18 |
| `30_backup_restore_pitr_dr` | 5 |
| `31_logging_error_signatures` | 4 |
| `32_upgrade_patch_readiness` | 6 |
| `33_bgwriter_memory_pressure` | 5 |
| `34_consistency_integrity_checks` | 5 |
| `35_pooler_proxy_diagnostics` | 5 |
| `36_cloud_provider_signals` | 5 |
| `37_object_lifecycle_capacity` | 12 |
| `38_observability_360` | 12 |
| `39_observer_agent_monitoring` | 10 |

## Scripts

| Area | Script | Title | Purpose | Sample Output |
| --- | --- | --- | --- | --- |
| `00_environment` | `00_environment/01_server_instance_overview.sql` | Server Instance Overview | Provide a quick PostgreSQL instance fingerprint for troubleshooting. | yes |
| `00_environment` | `00_environment/02_extensions_installed.sql` | Extensions Installed | List installed extensions and their schema/version. | yes |
| `00_environment` | `00_environment/03_database_catalog_overview.sql` | Database Catalog Overview | Show high-level object counts in the current database catalog. | yes |
| `01_database_size` | `01_database_size/01_databases_size.sql` | Databases Size | Rank all databases by total size. | yes |
| `01_database_size` | `01_database_size/02_current_database_size_breakdown.sql` | Current Database Size Breakdown | Break down current database storage into table, index, and TOAST components. | yes |
| `01_database_size` | `01_database_size/03_tablespaces_size.sql` | Tablespaces Size | Show tablespace usage to identify storage pressure by tablespace. | yes |
| `02_table_storage` | `02_table_storage/01_table_size_breakdown.sql` | Table Size Breakdown | Show per-table storage split (heap, index, TOAST, total). | yes |
| `02_table_storage` | `02_table_storage/02_top_largest_tables.sql` | Top Largest Tables | Quickly list the largest tables in the current database. | yes |
| `02_table_storage` | `02_table_storage/03_table_growth_baseline_snapshot.sql` | Table Growth Baseline Snapshot | Capture current table size and row estimate as a growth baseline snapshot. | yes |
| `02_table_storage` | `02_table_storage/04_relation_storage_parameters.sql` | Relation Storage Parameters | Inspect per-table storage settings (fillfactor, autovacuum overrides, etc.). | yes |
| `03_index_analysis` | `03_index_analysis/01_index_size_and_usage.sql` | Index Size And Usage | Correlate index size with usage counters to find expensive or cold indexes. | yes |
| `03_index_analysis` | `03_index_analysis/02_unused_indexes_candidates.sql` | Unused Indexes Candidates | Identify non-unique/non-primary indexes that have never been scanned. | yes |
| `03_index_analysis` | `03_index_analysis/03_duplicate_indexes.sql` | Duplicate Indexes | Detect duplicate index definitions on the same table. | yes |
| `03_index_analysis` | `03_index_analysis/04_index_maintenance_candidates.sql` | Index Maintenance Candidates | Highlight large indexes with low scan counts as maintenance/drop review candidates. | yes |
| `04_toast_lob_blob` | `04_toast_lob_blob/01_tables_with_toast.sql` | Tables With Toast | List tables that own TOAST tables and their TOAST size. | yes |
| `04_toast_lob_blob` | `04_toast_lob_blob/02_toast_heavy_tables.sql` | Toast Heavy Tables | Find tables where TOAST occupies a large share of total table size. | yes |
| `04_toast_lob_blob` | `04_toast_lob_blob/03_large_objects_summary.sql` | Large Objects Summary | Summarize large object (BLOB) footprint from pg_largeobject. | yes |
| `04_toast_lob_blob` | `04_toast_lob_blob/04_top_large_objects.sql` | Top Large Objects | Rank largest individual large objects (BLOBs) by size. | yes |
| `05_partitioning` | `05_partitioning/01_partitioned_tables_overview.sql` | Partitioned Tables Overview | Show partitioned tables, partition key definition, and child count. | yes |
| `05_partitioning` | `05_partitioning/02_partition_size_distribution.sql` | Partition Size Distribution | Show partition sizes under each parent table. | yes |
| `05_partitioning` | `05_partitioning/03_partitions_without_indexes.sql` | Partitions Without Indexes | Identify partitions that have zero indexes defined. | yes |
| `05_partitioning` | `05_partitioning/04_partitioning_recommendation_candidates.sql` | Partitioning Recommendation Candidates | Heuristically flag large, high-write tables as partitioning candidates. | yes |
| `05_partitioning` | `05_partitioning/05_partition_sme_decision_scorecard.sql` | Partition Sme Decision Scorecard | Provide an SME-style partitioning scorecard using size, data-span, write pressure, and scan behavior. | yes |
| `05_partitioning` | `05_partitioning/06_partition_target_table_deep_advisor.sql` | Partition Target Table Deep Advisor | Deep-dive partition advisor for a specific table and time column, with SME decision score and developer action steps. | yes |
| `05_partitioning` | `05_partitioning/07_partition_lab_generate_5gb_timeseries.sql` | Partition Lab Generate 5Gb Timeseries | Create an unpartitioned lab table with 5GB+ time-series data (5/10-year span) to test partition decisions. | yes |
| `06_activity_locks` | `06_activity_locks/01_active_sessions.sql` | Active Sessions | List active and idle sessions with query age and wait details. | yes |
| `06_activity_locks` | `06_activity_locks/02_blocking_and_blocked_sessions.sql` | Blocking And Blocked Sessions | Show blocked sessions and the blocker session details. | yes |
| `06_activity_locks` | `06_activity_locks/03_long_running_transactions.sql` | Long Running Transactions | Detect long-running transactions that can block VACUUM and generate bloat. | yes |
| `06_activity_locks` | `06_activity_locks/04_wait_events_summary.sql` | Wait Events Summary | Summarize wait events across sessions to spot dominant bottlenecks. | yes |
| `07_vacuum_bloat` | `07_vacuum_bloat/01_table_bloat_estimate.sql` | Table Bloat Estimate | Approximate per-table bloat impact using dead tuple density. | yes |
| `07_vacuum_bloat` | `07_vacuum_bloat/02_autovacuum_table_status.sql` | Autovacuum Table Status | Review vacuum/analyze recency and dead tuples per table. | yes |
| `07_vacuum_bloat` | `07_vacuum_bloat/03_freeze_age_risk.sql` | Freeze Age Risk | Identify tables approaching anti-wraparound vacuum risk. | yes |
| `07_vacuum_bloat` | `07_vacuum_bloat/04_dead_tuples_hotspots.sql` | Dead Tuples Hotspots | Rank tables by dead tuple count and dead tuple percentage. | yes |
| `07_vacuum_bloat` | `07_vacuum_bloat/05_vacuum_progress.sql` | Vacuum Progress | Monitor currently running VACUUM operations. | yes |
| `08_replication_ha` | `08_replication_ha/01_primary_replication_status.sql` | Primary Replication Status | Show standby status and lag metrics from a primary node. | yes |
| `08_replication_ha` | `08_replication_ha/02_standby_replay_status.sql` | Standby Replay Status | Report recovery/replay state when connected to a standby node. | yes |
| `08_replication_ha` | `08_replication_ha/03_replication_slots_health.sql` | Replication Slots Health | Inspect replication slots and retained WAL volume. | yes |
| `08_replication_ha` | `08_replication_ha/04_wal_generation_rate.sql` | WAL Generation Rate | Estimate WAL generation rate based on pg_stat_wal counters. | yes |
| `09_security_roles` | `09_security_roles/01_roles_and_membership.sql` | Roles And Membership | List roles and inherited role memberships. | yes |
| `09_security_roles` | `09_security_roles/02_high_privilege_roles.sql` | High Privilege Roles | Identify highly privileged roles (superuser, replication, bypass RLS). | yes |
| `09_security_roles` | `09_security_roles/03_table_grants_by_role.sql` | Table Grants By Role | Show table-level grants for non-system schemas. | yes |
| `09_security_roles` | `09_security_roles/04_default_privileges.sql` | Default Privileges | Inspect default privileges that apply to future objects. | yes |
| `10_maintenance_monitoring` | `10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql` | Bgwriter Checkpoint Stats | Review checkpointer and background writer behavior. | yes |
| `10_maintenance_monitoring` | `10_maintenance_monitoring/02_cache_hit_ratio.sql` | Cache Hit Ratio | Calculate cache hit ratios for tables and indexes. | yes |
| `10_maintenance_monitoring` | `10_maintenance_monitoring/03_top_statements_pg_stat_statements.sql` | Top Statements Pg Stat Statements | Rank expensive SQL statements by total execution time. | yes |
| `10_maintenance_monitoring` | `10_maintenance_monitoring/04_non_default_config.sql` | Non Default Config | List configuration parameters that differ from built-in defaults. | yes |
| `10_maintenance_monitoring` | `10_maintenance_monitoring/05_connection_capacity.sql` | Connection Capacity | Show connection utilization against max_connections. | yes |
| `11_performance_tuning` | `11_performance_tuning/01_top_queries_by_total_exec_time.sql` | Top Queries By Total Exec Time | Rank statements by cumulative execution time to identify biggest workload contributors. | yes |
| `11_performance_tuning` | `11_performance_tuning/02_top_queries_by_mean_exec_time.sql` | Top Queries By Mean Exec Time | Find high-latency statements (average execution time) with meaningful call counts. | yes |
| `11_performance_tuning` | `11_performance_tuning/03_temp_file_heavy_queries.sql` | Temp File Heavy Queries | Detect statements causing heavy temp file writes (sort/hash spill candidates). | yes |
| `11_performance_tuning` | `11_performance_tuning/04_io_bound_query_candidates.sql` | IO Bound Query Candidates | Flag queries with high physical read pressure relative to cache hits. | yes |
| `11_performance_tuning` | `11_performance_tuning/05_performance_related_settings.sql` | Performance Related Settings | Show key performance tuning settings in one result set. | yes |
| `11_performance_tuning` | `11_performance_tuning/06_function_hotspots.sql` | Function Hotspots | Identify expensive user-defined functions by total execution time. | yes |
| `12_planner_statistics` | `12_planner_statistics/01_tables_needing_analyze.sql` | Tables Needing Analyze | Identify tables where modifications have outpaced analyze activity. | yes |
| `12_planner_statistics` | `12_planner_statistics/02_seq_scan_hotspots.sql` | Seq Scan Hotspots | Highlight tables dominated by sequential scans (possible index or query design issue). | yes |
| `12_planner_statistics` | `12_planner_statistics/03_column_stats_profile.sql` | Column Stats Profile | Inspect planner statistics profile for user-table columns. | yes |
| `12_planner_statistics` | `12_planner_statistics/04_extended_stats_candidates.sql` | Extended Stats Candidates | Heuristically flag wide, high-write tables lacking extended statistics objects. | yes |
| `12_planner_statistics` | `12_planner_statistics/05_autovacuum_analyze_settings_by_table.sql` | Autovacuum Analyze Settings By Table | Show table-level reloptions that override analyze/autovacuum behavior. | yes |
| `12_planner_statistics` | `12_planner_statistics/06_planner_cost_settings.sql` | Planner Cost Settings | Report planner cost parameters that strongly influence execution plan selection. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/01_database_io_profile.sql` | Database IO Profile | Profile read/write, temp, and transaction behavior by database. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/02_table_io_hotspots.sql` | Table IO Hotspots | Identify tables with highest physical I/O pressure. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/03_index_io_hotspots.sql` | Index IO Hotspots | Show indexes with the most block reads/hits to target tuning/rebuild reviews. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/04_wal_archiver_health.sql` | WAL Archiver Health | Check WAL archiver success/failure and recency. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql` | Checkpoint Pressure Indicators | Detect checkpoint pressure and backend write burden. | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/06_temp_file_usage_by_database.sql` | Temp File Usage By Database | Rank databases by temp file usage (spill pressure indicator). | yes |
| `13_io_wal_checkpoints` | `13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql` | Pg Stat IO Overview Pg16 Plus | Provide consolidated I/O stats from pg_stat_io view. | yes |
| `14_connection_workload` | `14_connection_workload/01_connections_by_user_app_db.sql` | Connections By User App Db | Break down active connections by database, user, and application. | yes |
| `14_connection_workload` | `14_connection_workload/02_idle_in_transaction_risk.sql` | Idle In Transaction Risk | List idle-in-transaction sessions that can cause bloat and lock retention. | yes |
| `14_connection_workload` | `14_connection_workload/03_connection_state_distribution.sql` | Connection State Distribution | Summarize session states and average age per state. | yes |
| `14_connection_workload` | `14_connection_workload/04_role_connection_limit_risk.sql` | Role Connection Limit Risk | Compare current connections against role-level connection limits. | yes |
| `14_connection_workload` | `14_connection_workload/05_backend_type_distribution.sql` | Backend Type Distribution | Show backend process distribution by backend_type. | yes |
| `14_connection_workload` | `14_connection_workload/06_prepared_transactions_status.sql` | Prepared Transactions Status | List prepared transactions (2PC) and their age. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/01_create_capacity_repository.sql` | Create Capacity Repository | Create local repository tables for periodic capacity snapshots. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/02_capture_database_size_snapshot.sql` | Capture Database Size Snapshot | Capture point-in-time database sizes for growth tracking. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/03_capture_table_size_snapshot.sql` | Capture Table Size Snapshot | Capture table-level size and tuple estimates for growth trending. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/04_capture_index_size_snapshot.sql` | Capture Index Size Snapshot | Capture index size and scan count for index growth/utility trends. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/05_capture_connection_snapshot.sql` | Capture Connection Snapshot | Capture connection distribution snapshot for pool/capacity trending. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/06_capture_wal_snapshot.sql` | Capture WAL Snapshot | Capture WAL counter snapshots for WAL rate trend analysis. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/07_database_growth_report.sql` | Database Growth Report | Report database growth between first and latest snapshots in repository. | yes |
| `15_capacity_forecasting` | `15_capacity_forecasting/08_table_growth_report.sql` | Table Growth Report | Report top table growth between first and latest repository snapshots. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/01_database_xid_multixact_age.sql` | Database XID Multixact Age | Show XID and multixact age by database to assess wraparound risk. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/02_relation_filenode_mapping.sql` | Relation Filenode Mapping | Map logical relation names to relfilenode and tablespace internals. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/03_system_catalog_size_profile.sql` | System Catalog Size Profile | Profile largest system catalogs to understand metadata footprint. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/04_dependency_fanout_objects.sql` | Dependency Fanout Objects | Identify objects with high dependency fanout in catalog metadata. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql` | Fsm Vm Toast Size Breakdown | Break down main/FSM/VM/TOAST forks to inspect internal storage overhead. | yes |
| `16_internals_deep_dive` | `16_internals_deep_dive/06_visibility_and_freeze_profile.sql` | Visibility And Freeze Profile | Correlate visibility/freeze internals for table aging and maintenance planning. | yes |
| `17_execution_plans` | `17_execution_plans/01_plan_capture_prerequisites.sql` | Plan Capture Prerequisites | Verify settings required for reliable plan analysis and plan-related diagnostics. | yes |
| `17_execution_plans` | `17_execution_plans/02_explain_analyze_template.sql` | Explain Analyze Template | Template to read and understand execution plans for problematic queries. | yes |
| `17_execution_plans` | `17_execution_plans/03_generate_explain_for_top_queries.sql` | Generate Explain For Top Queries | Generate EXPLAIN command text for top queries from pg_stat_statements. | yes |
| `17_execution_plans` | `17_execution_plans/04_plan_red_flag_candidates.sql` | Plan Red Flag Candidates | Flag statements likely to have plan-level issues (spills, I/O-heavy, high variance). | yes |
| `18_long_queries_full_scans` | `18_long_queries_full_scans/01_active_long_queries.sql` | Active Long Queries | List currently running long queries and wait signals. | yes |
| `18_long_queries_full_scans` | `18_long_queries_full_scans/02_long_queries_from_statements.sql` | Long Queries From Statements | Rank historically slow queries using mean and total execution times. | yes |
| `18_long_queries_full_scans` | `18_long_queries_full_scans/03_short_vs_long_query_distribution.sql` | Short Vs Long Query Distribution | Classify query mix into short/medium/long buckets for optimization strategy choice. | yes |
| `18_long_queries_full_scans` | `18_long_queries_full_scans/04_full_scan_hotspot_tables.sql` | Full Scan Hotspot Tables | Identify large tables where sequential scans dominate access pattern. | yes |
| `19_dml_optimization` | `19_dml_optimization/01_write_heavy_tables.sql` | Write Heavy Tables | Rank tables by write volume to target DML optimization and maintenance. | yes |
| `19_dml_optimization` | `19_dml_optimization/02_hot_update_efficiency.sql` | Hot Update Efficiency | Evaluate HOT update efficiency (lower ratio may indicate index churn and write amplification). | yes |
| `19_dml_optimization` | `19_dml_optimization/03_missing_fk_supporting_indexes.sql` | Missing FK Supporting Indexes | Detect foreign keys lacking a matching index on referencing columns. | yes |
| `19_dml_optimization` | `19_dml_optimization/04_dml_bloat_pressure.sql` | Dml Bloat Pressure | Show write-heavy tables with dead tuple pressure (bloat risk). | yes |
| `20_design_matters` | `20_design_matters/01_tables_without_primary_keys.sql` | Tables Without Primary Keys | Identify user tables without primary keys. | yes |
| `20_design_matters` | `20_design_matters/02_wide_tables_profile.sql` | Wide Tables Profile | Profile table width and column counts to detect design patterns that can degrade performance. | yes |
| `20_design_matters` | `20_design_matters/03_overindexed_tables.sql` | Overindexed Tables | Find tables with potentially excessive index count relative to write activity. | yes |
| `20_design_matters` | `20_design_matters/04_high_nullability_columns.sql` | High Nullability Columns | Identify columns with high null fraction that may indicate schema redesign opportunities. | yes |
| `21_configuration_parameters` | `21_configuration_parameters/01_core_performance_settings.sql` | Core Performance Settings | Report core performance-related instance settings for baseline tuning. | yes |
| `21_configuration_parameters` | `21_configuration_parameters/02_wal_checkpoint_settings.sql` | WAL Checkpoint Settings | Show WAL and checkpoint settings that affect write latency and recovery behavior. | yes |
| `21_configuration_parameters` | `21_configuration_parameters/03_autovacuum_settings.sql` | Autovacuum Settings | Report autovacuum and freeze-related settings. | yes |
| `21_configuration_parameters` | `21_configuration_parameters/04_connection_timeout_settings.sql` | Connection Timeout Settings | Show connection and timeout settings that influence application behavior and contention. | yes |
| `22_application_orm_performance` | `22_application_orm_performance/01_n_plus_one_query_candidates.sql` | N Plus One Query Candidates | Flag very frequently called, short statements (common N+1 query symptom). | yes |
| `22_application_orm_performance` | `22_application_orm_performance/02_select_star_candidates.sql` | Select Star Candidates | Identify statements that use SELECT * and may fetch unnecessary columns. | yes |
| `22_application_orm_performance` | `22_application_orm_performance/03_chatty_small_result_queries.sql` | Chatty Small Result Queries | Detect chatty query patterns with many calls and tiny average row returns. | yes |
| `22_application_orm_performance` | `22_application_orm_performance/04_app_idle_in_transaction_risk.sql` | App Idle In Transaction Risk | Identify applications holding idle transactions that can block cleanup and increase latency. | yes |
| `23_functions_dynamic_sql` | `23_functions_dynamic_sql/01_function_execution_hotspots.sql` | Function Execution Hotspots | Rank user functions by execution cost. | yes |
| `23_functions_dynamic_sql` | `23_functions_dynamic_sql/02_dynamic_sql_function_inventory.sql` | Dynamic SQL Function Inventory | Inventory PL/pgSQL functions likely using dynamic SQL (EXECUTE keyword). | yes |
| `23_functions_dynamic_sql` | `23_functions_dynamic_sql/03_volatile_and_security_definer_functions.sql` | Volatile And Security Definer Functions | Audit VOLATILE and SECURITY DEFINER functions for performance and security review. | yes |
| `23_functions_dynamic_sql` | `23_functions_dynamic_sql/04_trigger_function_inventory.sql` | Trigger Function Inventory | List trigger functions and their table bindings. | yes |
| `24_complex_filter_search` | `24_complex_filter_search/01_like_ilike_query_candidates.sql` | Like Ilike Query Candidates | Find LIKE/ILIKE-heavy statements that may need trigram/full-text strategy. | yes |
| `24_complex_filter_search` | `24_complex_filter_search/02_jsonb_array_column_inventory.sql` | JSONB Array Column Inventory | Inventory JSON/JSONB/array columns that often need specialized indexing. | yes |
| `24_complex_filter_search` | `24_complex_filter_search/03_gin_gist_brin_index_inventory.sql` | GIN GiST BRIN Index Inventory | List advanced index access methods used for complex filtering/search patterns. | yes |
| `24_complex_filter_search` | `24_complex_filter_search/04_full_text_search_inventory.sql` | Full Text Search Inventory | Inventory full-text search building blocks (tsvector/tsquery related columns and indexes). | yes |
| `25_oltp_olap_goals` | `25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.sql` | Workload Signature OLTP Vs OLAP | Classify statement patterns as OLTP-like or OLAP-like based on latency, volume, and rows/call. | yes |
| `25_oltp_olap_goals` | `25_oltp_olap_goals/02_oltp_latency_goal_candidates.sql` | OLTP Latency Goal Candidates | Find high-frequency statements violating common OLTP latency expectations. | yes |
| `25_oltp_olap_goals` | `25_oltp_olap_goals/03_olap_throughput_candidates.sql` | OLAP Throughput Candidates | Detect analytic-style statements with heavy scans and high resource use. | yes |
| `25_oltp_olap_goals` | `25_oltp_olap_goals/04_mixed_workload_pressure.sql` | Mixed Workload Pressure | Summarize mixed-workload pressure indicators by database. | yes |
| `26_physical_cloud_diagnostics` | `26_physical_cloud_diagnostics/01_instance_platform_fingerprint.sql` | Instance Platform Fingerprint | Capture platform hints and runtime footprint for physical/cloud diagnosis. | yes |
| `26_physical_cloud_diagnostics` | `26_physical_cloud_diagnostics/02_io_latency_profile.sql` | IO Latency Profile | Profile I/O latency per database to detect storage-level bottlenecks. | yes |
| `26_physical_cloud_diagnostics` | `26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql` | Checkpoint Fsync Pressure | Detect checkpoint and fsync pressure indicative of storage or config issues. | yes |
| `26_physical_cloud_diagnostics` | `26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.sql` | Replication Slot WAL Retention Risk | Identify WAL retention risk from replication slots that can cause disk pressure. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/01_bottleneck_overview_dashboard.sql` | Bottleneck Overview Dashboard | Provide a single-row bottleneck overview across concurrency, I/O, temp usage, locks, and checkpoints. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/02_waits_and_blocking_details.sql` | Waits And Blocking Details | Show wait profile and blocker/blocked chains for immediate bottleneck diagnosis. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql` | Missing Index Candidates From Scan Pressure | Detect large tables with heavy sequential scan pressure as index candidate hotspots. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/04_missing_fk_index_candidates.sql` | Missing FK Index Candidates | Find foreign keys without supporting indexes on referencing columns. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/05_parameter_tuning_advisor.sql` | Parameter Tuning Advisor | Evaluate key performance parameters and output tuning recommendations with severity. | yes |
| `27_high_speed_tuning` | `27_high_speed_tuning/06_query_tuning_action_queue.sql` | Query Tuning Action Queue | Build an actionable queue of expensive queries with root-cause hints and next actions. | yes |
| `27_migration_validation` | `27_migration_validation/01_oracle_to_postgres_360_health_report.sql` | Oracle To Postgres 360 Health Report | Generate a single HTML health-check report for PostgreSQL after Oracle migration. | yes |
| `27_migration_validation` | `27_migration_validation/02_seed_v1_test_issues.sql` | Seed V1 Test Issues | Seed deterministic Oracle->PostgreSQL migration issues for V1 report validation. | yes |
| `27_migration_validation` | `27_migration_validation/03_fix_v1_test_issues.sql` | Fix V1 Test Issues | Resolve seeded V1 migration issues created by 02_seed_v1_test_issues.sql. | yes |
| `27_migration_validation` | `27_migration_validation/04_v1_sanity_checks.sql` | V1 Sanity Checks | Sanity assertions for V1 migration validation workflow. | yes |
| `27_migration_validation` | `27_migration_validation/05_seed_v2_test_issues.sql` | Seed V2 Test Issues | Seed practical, deterministic migration/performance issues using a dedicated lab schema. | yes |
| `27_migration_validation` | `27_migration_validation/06_fix_v2_test_issues.sql` | Fix V2 Test Issues | Resolve V2 seeded migration/performance issues in migration_v2_lab. | yes |
| `27_migration_validation` | `27_migration_validation/07_v2_sanity_checks.sql` | V2 Sanity Checks | PASS/FAIL assertions for V2 migration/performance issue scenarios. | yes |
| `27_migration_validation` | `27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql` | Oracle To Postgres Enterprise Report V2 | Generate an enterprise-style HTML report with deep object coverage and issue diagnostics. | yes |
| `27_migration_validation` | `27_migration_validation/09_enterprise_takeover_gate_v3.sql` | Enterprise Takeover Gate V3 | Enterprise Day-1 takeover gate for Oracle -> PostgreSQL migration. | yes |
| `28_pgss_resource_attribution` | `28_pgss_resource_attribution/01_pgss_query_resource_percent.sql` | Pg Stat Statements Query Resource Percent | Attribute query resource usage using pg_stat_statements with CPU/IO/memory-spill percentages. | yes |
| `28_pgss_resource_attribution` | `28_pgss_resource_attribution/02_pgss_resource_percent_by_database.sql` | Pg Stat Statements Resource Percent By Database | Show resource percentage attribution by database from pg_stat_statements. | yes |
| `28_pgss_resource_attribution` | `28_pgss_resource_attribution/03_pgss_resource_percent_by_user.sql` | Pg Stat Statements Resource Percent By User | Show resource percentage attribution by login role from pg_stat_statements. | yes |
| `28_pgss_resource_attribution` | `28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.sql` | Pg Stat Statements Query Infra Tier Classification | Classify queries into infra pressure tiers (CPU/IO/Memory spill) using percentages. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/01_object_type_inventory.sql` | Object Type Inventory | Provide a one-shot inventory of core object types and migration-mapped object equivalents. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/02_table_pk_fk_health.sql` | Table PK FK Health | Show table-level PK/FK/index health for user schemas. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/03_tables_missing_primary_key.sql` | Tables Missing Primary Key | Identify tables missing primary keys and generate starter DDL suggestions. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/04_missing_fk_supporting_indexes.sql` | Missing FK Supporting Indexes | Find foreign keys where referencing columns are not backed by a suitable index prefix. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/05_missing_join_column_indexes.sql` | Missing Join Column Indexes | Suggest indexes for likely join columns (id/key-style columns) under scan pressure. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/06_identifier_casing_risks.sql` | Identifier Casing Risks | Find mixed/upper-case identifiers that require quoted SQL and increase migration risk. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/07_sequence_ownership_health.sql` | Sequence Ownership Health | Audit sequence ownership and attachment to table columns. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/08_trigger_inventory.sql` | Trigger Inventory | Inventory user triggers with firing mode and trigger function binding. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/09_grant_exposure_audit.sql` | Grant Exposure Audit | Audit privilege exposure, with focus on PUBLIC grants and grant-option chains. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/10_function_procedure_inventory.sql` | Function Procedure Inventory | Inventory functions/procedures with performance and safety attributes. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/11_partition_health.sql` | Partition Health | Assess partitioned table coverage, size distribution, and index gaps on leaf partitions. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/12_user_defined_type_inventory.sql` | User Defined Type Inventory | Inventory custom types and show where they are used in table columns. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/13_insert_copy_activity.sql` | Insert Copy Activity | Monitor INSERT/COPY pressure using active COPY progress and table write counters. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/14_fdw_inventory.sql` | FDW Inventory | Inventory FDW objects (wrapper, servers, mappings, and foreign tables). | yes |
| `29_object_inventory_health` | `29_object_inventory_health/15_oracle_package_synonym_mapping.sql` | Oracle Package Synonym Mapping | Provide Oracle PACKAGE/SYNONYM migration mapping visibility in PostgreSQL. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/16_kettle_etl_activity_signals.sql` | Kettle Etl Activity Signals | Detect ETL/KETTLE-like activity patterns from active sessions and role naming. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/17_object_bloat_hotspots.sql` | Object Bloat Hotspots | Highlight table bloat pressure using dead tuple and scan behavior proxies. | yes |
| `29_object_inventory_health` | `29_object_inventory_health/18_object_query_hotspots_pgss.sql` | Object Query Hotspots Pg Stat Statements | Show top query hotspots with coarse object token extraction from SQL text. | yes |
| `30_backup_restore_pitr_dr` | `30_backup_restore_pitr_dr/01_backup_pitr_configuration_health.sql` | Backup Pitr Configuration Health | Validate backup/PITR configuration prerequisites and highlight gaps for recoverability. | yes |
| `30_backup_restore_pitr_dr` | `30_backup_restore_pitr_dr/02_wal_archiving_gap_and_lag.sql` | WAL Archiving Gap And Lag | Detect WAL archiving failure trends, archive recency gaps, and slot-retention pressure. | yes |
| `30_backup_restore_pitr_dr` | `30_backup_restore_pitr_dr/03_restore_to_timestamp_quick_test.sql` | Restore To Timestamp Quick Test | Quick SQL-only feasibility check for "Can we restore to timestamp X right now?". | yes |
| `30_backup_restore_pitr_dr` | `30_backup_restore_pitr_dr/04_dr_rto_rpo_replication_evidence.sql` | DR RTO RPO Replication Evidence | Produce DR evidence for RPO/RTO discussions from replication and replay state. | yes |
| `30_backup_restore_pitr_dr` | `30_backup_restore_pitr_dr/05_backup_restore_evidence_contract.sql` | Backup Restore Evidence Contract | Check whether a backup/restore evidence table exists for trend reporting (duration, size, success). | yes |
| `31_logging_error_signatures` | `31_logging_error_signatures/01_logging_configuration_sanity.sql` | Logging Configuration Sanity | Validate key logging parameters for performance troubleshooting and incident diagnostics. | yes |
| `31_logging_error_signatures` | `31_logging_error_signatures/02_error_signature_indicators.sql` | Error Signature Indicators | Surface recurring error-like signatures from PostgreSQL statistics (deadlocks, conflicts, rollback spikes, temp storms). | yes |
| `31_logging_error_signatures` | `31_logging_error_signatures/03_slow_query_log_vs_pgss_correlation.sql` | Slow Query Log Vs Pg Stat Statements Correlation | Correlate slow-query logging threshold with pg_stat_statements hotspots. | yes |
| `31_logging_error_signatures` | `31_logging_error_signatures/04_lock_wait_deadlock_signatures.sql` | Lock Wait Deadlock Signatures | Capture active lock-wait chains and deadlock-prone signatures from current activity. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/01_version_upgrade_path_overview.sql` | Version Upgrade Path Overview | Show current PostgreSQL version posture and supported target path across PG15-PG18. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/02_extension_version_drift_dependencies.sql` | Extension Version Drift Dependencies | Detect extension version drift and quantify extension-owned dependency footprint. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/03_preupgrade_invalid_objects_gate.sql` | Preupgrade Invalid Objects Gate | Identify invalid indexes and NOT VALID constraints that can break upgrade confidence. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/04_collation_version_mismatch_risk.sql` | Collation Version Mismatch Risk | Detect collation version mismatches that can cause index/order behavior drift after OS/DB upgrades. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/05_postupgrade_query_regression_watchlist_pgss.sql` | Postupgrade Query Regression Watchlist Pg Stat Statements | Build a post-upgrade query watchlist for plan/latency regressions using pg_stat_statements. | yes |
| `32_upgrade_patch_readiness` | `32_upgrade_patch_readiness/06_config_file_unknown_or_deprecated_gucs.sql` | Config File Unknown Or Deprecated Gucs | Identify configuration-file errors and unapplied parameters that can appear after upgrade/patch changes. | yes |
| `33_bgwriter_memory_pressure` | `33_bgwriter_memory_pressure/01_bgwriter_checkpointer_pressure.sql` | Bgwriter Checkpointer Pressure | Quantify checkpointer/bgwriter pressure and backend-write fallback behavior. | yes |
| `33_bgwriter_memory_pressure` | `33_bgwriter_memory_pressure/02_wal_writer_archiver_pressure.sql` | WAL Writer Archiver Pressure | Diagnose WAL writer and archiver pressure that can manifest as high IO/CPU latency. | yes |
| `33_bgwriter_memory_pressure` | `33_bgwriter_memory_pressure/03_autovacuum_worker_pressure.sql` | Autovacuum Worker Pressure | Measure autovacuum worker saturation and table backlog pressure. | yes |
| `33_bgwriter_memory_pressure` | `33_bgwriter_memory_pressure/04_parallel_worker_pressure.sql` | Parallel Worker Pressure | Inspect parallel worker utilization and leader/worker activity pressure. | yes |
| `33_bgwriter_memory_pressure` | `33_bgwriter_memory_pressure/05_temp_spill_work_mem_pressure.sql` | Temp Spill Work Mem Pressure | Identify memory-pressure symptoms from temp spill volume and work_mem-sensitive query behavior. | yes |
| `34_consistency_integrity_checks` | `34_consistency_integrity_checks/01_invalid_indexes_and_constraints.sql` | Invalid Indexes And Constraints | Detect invalid indexes and unvalidated constraints that indicate integrity or migration risk. | yes |
| `34_consistency_integrity_checks` | `34_consistency_integrity_checks/02_checksum_status_and_failures.sql` | Checksum Status And Failures | Show checksum posture and checksum-failure evidence when available. | yes |
| `34_consistency_integrity_checks` | `34_consistency_integrity_checks/03_toast_catalog_consistency_signals.sql` | Toast Catalog Consistency Signals | Detect TOAST/catalog linkage anomalies that can indicate deeper metadata inconsistencies. | yes |
| `34_consistency_integrity_checks` | `34_consistency_integrity_checks/04_amcheck_readiness_and_candidate_commands.sql` | Amcheck Readiness And Candidate Commands | Assess amcheck readiness and generate candidate bt_index_check commands for large indexes. | yes |
| `34_consistency_integrity_checks` | `34_consistency_integrity_checks/05_xid_visibility_integrity_risk.sql` | XID Visibility Integrity Risk | Surface XID/multixact age and vacuum staleness risks that can lead to integrity incidents. | yes |
| `35_pooler_proxy_diagnostics` | `35_pooler_proxy_diagnostics/01_connection_saturation_queue_risk.sql` | Connection Saturation Queue Risk | Measure connection saturation and queue-risk proxy metrics from PostgreSQL side. | yes |
| `35_pooler_proxy_diagnostics` | `35_pooler_proxy_diagnostics/02_connection_distribution_by_app_user.sql` | Connection Distribution By App User | Show connection distribution by user/application/client for pool right-sizing and hotspot detection. | yes |
| `35_pooler_proxy_diagnostics` | `35_pooler_proxy_diagnostics/03_prepared_statement_pooling_risk.sql` | Prepared Statement Pooling Risk | Detect prepared-statement patterns that can break or degrade transaction pooling modes. | yes |
| `35_pooler_proxy_diagnostics` | `35_pooler_proxy_diagnostics/04_tx_pooling_incompatible_patterns_pgss.sql` | Tx Pooling Incompatible Patterns Pg Stat Statements | Identify query patterns that are problematic in transaction pooling modes. | yes |
| `35_pooler_proxy_diagnostics` | `35_pooler_proxy_diagnostics/05_pooler_proxy_inventory_signals.sql` | Pooler Proxy Inventory Signals | Inventory pooler/proxy related extensions, FDWs, and operational signals. | yes |
| `36_cloud_provider_signals` | `36_cloud_provider_signals/01_managed_service_fingerprint.sql` | Managed Service Fingerprint | Infer managed-service footprint and enumerate provider-specific settings exposed in PostgreSQL. | yes |
| `36_cloud_provider_signals` | `36_cloud_provider_signals/02_parameter_pending_restart_drift.sql` | Parameter Pending Restart Drift | Detect pending-restart parameters and configuration drift from defaults. | yes |
| `36_cloud_provider_signals` | `36_cloud_provider_signals/03_replica_lag_failover_signals.sql` | Replica Lag Failover Signals | Provide portable failover and replica-lag signals for managed or self-managed platforms. | yes |
| `36_cloud_provider_signals` | `36_cloud_provider_signals/04_storage_iops_temp_wal_pressure.sql` | Storage Iops Temp WAL Pressure | Summarize storage/IO pressure signals often correlated with cloud IOPS or burst-balance incidents. | yes |
| `36_cloud_provider_signals` | `36_cloud_provider_signals/05_cloud_incident_window_checklist.sql` | Cloud Incident Window Checklist | Provide cloud incident-window checklist prompts mapped to likely provider consoles. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/01_create_lifecycle_repository.sql` | Create Lifecycle Repository | Create repository tables for lifecycle events, usage snapshots, and growth tracking. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/02_create_ddl_event_triggers.sql` | Create Ddl Event Triggers | Create DDL event triggers to capture object create/alter/drop timestamps for lifecycle monitoring. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/03_create_snapshot_procedures.sql` | Create Snapshot Procedures | Create procedures to capture periodic lifecycle/capacity snapshots and purge old history. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/04_capture_snapshot_now.sql` | Capture Snapshot Now | Capture an immediate snapshot for index/table/object lifecycle baselining. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/05_create_index_lifecycle_views.sql` | Create Index Lifecycle Views | Create index lifecycle views with inferred last-use timestamp and create/drop event tracking. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/06_create_table_modification_views.sql` | Create Table Modification Views | Create table modification delta views (insert/update/delete/HOT) and monthly rollups. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/07_create_growth_views.sql` | Create Growth Views | Create monthly growth views for objects and databases. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/08_create_action_advisory_views.sql` | Create Action Advisory Views | Create advisory views for unused indexes, high-growth objects, and high-DML pressure tables. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/09_scheduler_runbook.sql` | Scheduler Runbook | Provide scheduling commands for periodic snapshot capture (pg_cron or external scheduler). | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/10_monthly_capacity_report.sql` | Monthly Capacity Report | Produce a monthly DBA report for database growth, object growth, and action queue. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/11_index_usage_lab_create_use_drop_demo.sql` | Index Usage Lab Create Use Drop Demo | Demo index lifecycle by creating indexes, forcing index scans, and dropping an unused index. | yes |
| `37_object_lifecycle_capacity` | `37_object_lifecycle_capacity/12_table_modification_tracking_demo.sql` | Table Modification Tracking Demo | Demonstrate INSERT/UPDATE/DELETE delta monitoring similar to Oracle DBA_TAB_MODIFICATIONS. | yes |
| `38_observability_360` | `38_observability_360/01_instance_health_360_dashboard.sql` | Instance Health 360 Dashboard | Provide one command-line health dashboard across sessions, locks, cache, temp, WAL, checkpoints, and replication. | yes |
| `38_observability_360` | `38_observability_360/02_cloudwatch_metric_equivalents.sql` | CloudWatch Metric Equivalents | Map common RDS/CloudWatch metrics to PostgreSQL SQL-visible counters and identify host-only gaps. | yes |
| `38_observability_360` | `38_observability_360/03_stat_view_coverage_check.sql` | Stat View Coverage Check | Check whether important PostgreSQL observability views, extensions, and settings are available. | yes |
| `38_observability_360` | `38_observability_360/04_wait_event_hotspots.sql` | Wait Event Hotspots | Summarize current wait events by type, event, state, backend type, application, and database. | yes |
| `38_observability_360` | `38_observability_360/05_database_activity_metrics.sql` | Database Activity Metrics | Show per-database transaction, cache, row, temp, conflict, deadlock, and timing counters in one place. | yes |
| `38_observability_360` | `38_observability_360/06_table_index_activity_heatmap.sql` | Table Index Activity Heatmap | Rank tables by read/write pressure, dead tuples, sequential scans, index scans, and storage size. | yes |
| `38_observability_360` | `38_observability_360/07_wal_checkpoint_archiver_dashboard.sql` | WAL Checkpoint Archiver Dashboard | Summarize WAL generation, WAL write pressure, checkpoint pressure, and archive health. | yes |
| `38_observability_360` | `38_observability_360/08_autovacuum_vacuum_analyze_progress.sql` | Autovacuum Vacuum Analyze Progress | Show current vacuum/analyze progress and tables with the largest cleanup/analyze backlog. | yes |
| `38_observability_360` | `38_observability_360/09_replication_and_slot_dashboard.sql` | Replication And Slot Dashboard | Show primary-side standby lag, standby receiver state, replication slots, and WAL retention risk. | yes |
| `38_observability_360` | `38_observability_360/10_query_capture_quality_pgss.sql` | Query Capture Quality PGSS | Verify pg_stat_statements capture quality and show whether query history is useful enough for tuning. | yes |
| `38_observability_360` | `38_observability_360/11_growth_and_capacity_snapshot_now.sql` | Growth And Capacity Snapshot Now | Capture a current one-shot view of database size, largest relations, WAL retention, XID age, and temp usage. | yes |
| `38_observability_360` | `38_observability_360/12_sme_triage_command_router.sql` | SME Triage Command Router | Map common DBA symptoms to the best scripts in this repository so users can move from signal to diagnosis quickly. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/01_create_observer_repository.sql` | Create Observer Repository | Create repository tables for observer-agent snapshots, findings, thresholds, and run history. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/02_capture_observer_snapshot.sql` | Capture Observer Snapshot | Capture current observer metrics, score health, and store findings with recommended next scripts. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/03_health_score_dashboard.sql` | Health Score Dashboard | Show latest observer health score, status, metric summary, and open findings. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/04_active_incident_detector.sql` | Active Incident Detector | Detect current performance incidents from live PostgreSQL metrics without requiring stored snapshots. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/05_wait_lock_io_wal_classifier.sql` | Wait Lock IO WAL Classifier | Classify current pressure into wait, lock, I/O, temp, WAL, archive, and replication domains. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/06_top_root_cause_action_queue.sql` | Top Root Cause Action Queue | Build a prioritized action queue from live signals and pg_stat_statements hotspots. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/07_baseline_deviation_report.sql` | Baseline Deviation Report | Compare the latest observer snapshot with the previous snapshot to highlight fast-changing metrics. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/08_sla_risk_dashboard.sql` | SLA Risk Dashboard | Summarize live availability, latency, throughput, recoverability, and maintenance risks. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/09_generate_agent_summary.sql` | Generate Agent Summary | Generate a concise observer-agent summary with health, likely issues, and next scripts. | yes |
| `39_observer_agent_monitoring` | `39_observer_agent_monitoring/10_observer_scheduler_runbook.sql` | Observer Scheduler Runbook | Provide scheduler commands and operating guidance for running the observer-agent scripts continuously. | yes |

## Conventions

- File names use numeric prefixes so each area has a stable run order.
- Every SQL file starts with `PostgreSQL DBA Script`, `Purpose`, `Area`, `Usage`, `Sample Output`, and `Notes`.
- Every SQL file keeps an embedded `SAMPLE_OUTPUT_BEGIN` / `SAMPLE_OUTPUT_END` block at the bottom for expected result shape.
