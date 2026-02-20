# Object Lifecycle and Capacity Monitoring

Purpose: Build PostgreSQL-native monitoring for index lifecycle, table modifications, object growth, and monthly capacity decisions.

## Why This Area

- Oracle `DBA_TAB_MODIFICATIONS` style tracking is approximated in PostgreSQL using `pg_stat_user_tables` snapshots.
- PostgreSQL does not store native `created_date`/`dropped_date` history for all objects.
- This area adds persistent snapshots + DDL event logging + advisory views.

## Run Order

1. `01_create_lifecycle_repository.sql`
2. `02_create_ddl_event_triggers.sql`
3. `03_create_snapshot_procedures.sql`
4. `04_capture_snapshot_now.sql`
5. `05_create_index_lifecycle_views.sql`
6. `06_create_table_modification_views.sql`
7. `07_create_growth_views.sql`
8. `08_create_action_advisory_views.sql`
9. `09_scheduler_runbook.sql`
10. `10_monthly_capacity_report.sql`
11. `11_index_usage_lab_create_use_drop_demo.sql`
12. `12_table_modification_tracking_demo.sql`

## Main Outputs

- Index lifecycle: first seen, created event timestamp, last usage delta timestamp, dropped event timestamp.
- Drop governance: 45-day hold window and hard blocks for primary/constraint/unique indexes before candidate drop.
- Table modification deltas (insert/update/delete/HOT) by month.
- Object/database growth by month.
- Action queue for unused indexes, high-growth objects, and high-churn tables.
- Demo flow: create indexes, force index usage, capture snapshots, drop unused index, verify lifecycle status.

## Operational Notes

- Event triggers require superuser privileges.
- `pg_stat_*` counters reset on restart/reset; views handle reset boundaries with delta logic.
- `pg_cron` is optional; script `09` provides both `pg_cron` and external scheduler guidance.
- For quick navigation to `Usage` and embedded sample sections, see `SCRIPT_USAGE_SAMPLE_INDEX.md`.
