# Performance Tuning Coverage Map

Purpose: Map performance topics to script areas so teams can quickly diagnose root causes.

## Topic to Area Mapping

- `CloudWatch-style first look and command-line 360 observability`
  - `38_observability_360/01_instance_health_360_dashboard.sql`
  - `38_observability_360/02_cloudwatch_metric_equivalents.sql`
  - `38_observability_360/03_stat_view_coverage_check.sql`
  - `38_observability_360/12_sme_triage_command_router.sql`

- `Observer-agent monitoring, health score, incident detection, and action routing`
  - `39_observer_agent_monitoring/02_capture_observer_snapshot.sql`
  - `39_observer_agent_monitoring/03_health_score_dashboard.sql`
  - `39_observer_agent_monitoring/04_active_incident_detector.sql`
  - `39_observer_agent_monitoring/06_top_root_cause_action_queue.sql`
  - `39_observer_agent_monitoring/09_generate_agent_summary.sql`

- `Optimize PostgreSQL for high speed and tune database parameters`
  - `27_high_speed_tuning/01_bottleneck_overview_dashboard.sql`
  - `27_high_speed_tuning/05_parameter_tuning_advisor.sql`
  - `27_high_speed_tuning/06_query_tuning_action_queue.sql`

- `PgAdmin-friendly top 10 SME query deep dives`
  - `11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql`
  - `11_performance_tuning/08_top_10_temp_disk_spill_queries_pgadmin.sql`
  - `11_performance_tuning/09_top_10_memory_pressure_queries_pgadmin.sql`
  - `11_performance_tuning/10_active_top_10_runtime_pressure_pgadmin.sql`

- `PgAdmin-safe 360 diagnostics and incident routing`
  - `40_pgadmin_safe_diagnostics/01_pgadmin_compatibility_audit.sql`
  - `40_pgadmin_safe_diagnostics/05_pgadmin_safe_pg_stat_statements_quality.sql`
  - `40_pgadmin_safe_diagnostics/06_pgadmin_safe_cloudwatch_metric_equivalents.sql`
  - `40_pgadmin_safe_diagnostics/09_pgadmin_safe_observer_health_dashboard.sql`
  - `40_pgadmin_safe_diagnostics/10_pgadmin_safe_root_cause_action_queue.sql`
  - `40_pgadmin_safe_diagnostics/12_pgadmin_safe_sme_diagnosis_router.sql`

- `Detect bottlenecks and find missing indexes with ease`
  - `27_high_speed_tuning/02_waits_and_blocking_details.sql`
  - `27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql`
  - `27_high_speed_tuning/04_missing_fk_index_candidates.sql`

- `CPU/IO/Memory percentage by query and infrastructure-level attribution (pg_stat_statements proxy)`
  - `28_pgss_resource_attribution/01_pgss_query_resource_percent.sql`
  - `28_pgss_resource_attribution/02_pgss_resource_percent_by_database.sql`
  - `28_pgss_resource_attribution/03_pgss_resource_percent_by_user.sql`
  - `28_pgss_resource_attribution/04_pgss_query_infra_tier_classification.sql`

- `Long Queries and Full Scans`
  - `18_long_queries_full_scans/01_active_long_queries.sql`
  - `18_long_queries_full_scans/02_long_queries_from_statements.sql`
  - `18_long_queries_full_scans/04_full_scan_hotspot_tables.sql`
  - `11_performance_tuning/04_io_bound_query_candidates.sql`

- `Long Queries: Additional Techniques`
  - `17_execution_plans/03_generate_explain_for_top_queries.sql`
  - `17_execution_plans/04_plan_red_flag_candidates.sql`
  - `11_performance_tuning/03_temp_file_heavy_queries.sql`
  - `13_io_wal_checkpoints/06_temp_file_usage_by_database.sql`

- `Optimizing Data Modification`
  - `19_dml_optimization/01_write_heavy_tables.sql`
  - `19_dml_optimization/02_hot_update_efficiency.sql`
  - `19_dml_optimization/03_missing_fk_supporting_indexes.sql`
  - `19_dml_optimization/04_dml_bloat_pressure.sql`

- `Design Matters`
  - `20_design_matters/01_tables_without_primary_keys.sql`
  - `20_design_matters/02_wide_tables_profile.sql`
  - `20_design_matters/03_overindexed_tables.sql`
  - `20_design_matters/04_high_nullability_columns.sql`

- `Configuration Parameters`
  - `21_configuration_parameters/01_core_performance_settings.sql`
  - `21_configuration_parameters/02_wal_checkpoint_settings.sql`
  - `21_configuration_parameters/03_autovacuum_settings.sql`
  - `21_configuration_parameters/04_connection_timeout_settings.sql`

- `Application Development and Performance`
  - `22_application_orm_performance/01_n_plus_one_query_candidates.sql`
  - `22_application_orm_performance/03_chatty_small_result_queries.sql`
  - `14_connection_workload/01_connections_by_user_app_db.sql`
  - `14_connection_workload/02_idle_in_transaction_risk.sql`

- `Functions`
  - `23_functions_dynamic_sql/01_function_execution_hotspots.sql`
  - `11_performance_tuning/06_function_hotspots.sql`

- `Dynamic SQL`
  - `23_functions_dynamic_sql/02_dynamic_sql_function_inventory.sql`
  - `23_functions_dynamic_sql/03_volatile_and_security_definer_functions.sql`

- `Avoiding ORM Pitfalls`
  - `22_application_orm_performance/01_n_plus_one_query_candidates.sql`
  - `22_application_orm_performance/02_select_star_candidates.sql`
  - `22_application_orm_performance/04_app_idle_in_transaction_risk.sql`

- `More Complex Filtering and Search`
  - `24_complex_filter_search/01_like_ilike_query_candidates.sql`
  - `24_complex_filter_search/02_jsonb_array_column_inventory.sql`
  - `24_complex_filter_search/03_gin_gist_brin_index_inventory.sql`
  - `24_complex_filter_search/04_full_text_search_inventory.sql`

- `Ultimate Optimization Algorithm (Systemic Optimization)`
  - `25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.sql`
  - `25_oltp_olap_goals/04_mixed_workload_pressure.sql`
  - `26_physical_cloud_diagnostics/01_instance_platform_fingerprint.sql`
  - `26_physical_cloud_diagnostics/02_io_latency_profile.sql`

- `Identify optimization goals in OLTP and OLAP systems`
  - `25_oltp_olap_goals/01_workload_signature_oltp_vs_olap.sql`
  - `25_oltp_olap_goals/02_oltp_latency_goal_candidates.sql`
  - `25_oltp_olap_goals/03_olap_throughput_candidates.sql`

- `Understanding Execution Plans`
  - `17_execution_plans/01_plan_capture_prerequisites.sql`
  - `17_execution_plans/02_explain_analyze_template.sql`
  - `17_execution_plans/03_generate_explain_for_top_queries.sql`
  - `17_execution_plans/04_plan_red_flag_candidates.sql`

## Root Cause Dimensions

- `SQL/query shape`: long query, full scan, ORM chatty query, complex filter scripts.
- `Schema/index design`: design matters, missing FK index, index and planner sections.
- `Runtime behavior`: activity/locks, wait events, function hotspots.
- `Storage and I/O`: database/table/index size, WAL/checkpoint, I/O latency scripts, CloudWatch equivalents, and metric-specific RDS/Aurora PostgreSQL deep dives.
- `Infrastructure (physical/cloud)`: platform fingerprint, fsync/checkpoint pressure, replication slot WAL retention, provider-console-only gap checks.
- `Workload goal alignment`: OLTP vs OLAP classification and mixed workload pressure.
