# 37_object_lifecycle_capacity

Object lifecycle repository, DDL trigger, snapshots, advisory views, and capacity reports.

Scripts in this area: `12`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @37_object_lifecycle_capacity/<script>.sql`.

## Scripts

- `01_create_lifecycle_repository.sql`
- `02_create_ddl_event_triggers.sql`
- `03_create_snapshot_procedures.sql`
- `04_capture_snapshot_now.sql`
- `05_create_index_lifecycle_views.sql`
- `06_create_table_modification_views.sql`
- `07_create_growth_views.sql`
- `08_create_action_advisory_views.sql`
- `09_scheduler_runbook.sql`
- `10_monthly_capacity_report.sql`
- `11_index_usage_lab_create_use_drop_demo.sql`
- `12_table_modification_tracking_demo.sql`
