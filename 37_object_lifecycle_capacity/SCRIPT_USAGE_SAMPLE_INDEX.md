# Script Usage and Sample Output Index

Use this as a quick pointer for where each script's `Usage` section and embedded sample output block start.

| Script | Purpose | Usage Line | Sample Output Line |
|---|---|---:|---:|
| `01_create_lifecycle_repository.sql` | Create repository tables for lifecycle events, usage snapshots, and growth tracking. | 4 | 141 |
| `02_create_ddl_event_triggers.sql` | Create DDL event triggers to capture object create/alter/drop timestamps for lifecycle monitoring. | 4 | 115 |
| `03_create_snapshot_procedures.sql` | Create procedures to capture periodic lifecycle/capacity snapshots and purge old history. | 4 | 259 |
| `04_capture_snapshot_now.sql` | Capture an immediate snapshot for index/table/object lifecycle baselining. | 4 | 36 |
| `05_create_index_lifecycle_views.sql` | Create index lifecycle views with inferred last-use timestamp and create/drop event tracking. | 4 | 232 |
| `06_create_table_modification_views.sql` | Create table modification delta views (insert/update/delete/HOT) and monthly rollups. | 4 | 107 |
| `07_create_growth_views.sql` | Create monthly growth views for objects and databases. | 4 | 101 |
| `08_create_action_advisory_views.sql` | Create advisory views for unused indexes, high-growth objects, and high-DML pressure tables. | 4 | 107 |
| `09_scheduler_runbook.sql` | Provide scheduling commands for periodic snapshot capture (pg_cron or external scheduler). | 4 | 28 |
| `10_monthly_capacity_report.sql` | Produce a monthly DBA report for database growth, object growth, and action queue. | 4 | 43 |
| `11_index_usage_lab_create_use_drop_demo.sql` | Demo index lifecycle by creating indexes, forcing index scans, and dropping an unused index. | 4 | 89 |
| `12_table_modification_tracking_demo.sql` | Demonstrate INSERT/UPDATE/DELETE delta monitoring similar to Oracle DBA_TAB_MODIFICATIONS. | 4 | 95 |

Quick checks:

```bash
ROOT="/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/37_object_lifecycle_capacity"
rg -n "^Usage:|SAMPLE_OUTPUT_BEGIN|SAMPLE_OUTPUT_END" "$ROOT"/*.sql
```
