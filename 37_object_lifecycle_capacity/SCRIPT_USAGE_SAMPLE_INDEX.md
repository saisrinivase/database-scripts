# Oracle Object Lifecycle Capacity Script Index

This branch uses Oracle-native lifecycle scripts. Run setup scripts in order when you want a local lifecycle repository.

## Recommended Order

1. `01_create_lifecycle_repository.sql`
2. `02_create_ddl_event_triggers.sql`
3. `03_create_snapshot_procedures.sql`
4. `04_capture_snapshot_now.sql`
5. `05_create_index_lifecycle_views.sql` through `08_create_action_advisory_views.sql`
6. `09_scheduler_runbook.sql` for optional recurring capture through `DBMS_SCHEDULER`
7. `10_monthly_capacity_report.sql` for reporting

Review every DDL script before running it in production.
