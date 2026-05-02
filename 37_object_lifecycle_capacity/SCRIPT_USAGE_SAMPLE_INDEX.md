# MySQL Object Lifecycle Capacity Script Index

Run setup scripts in order when you want a local lifecycle repository.

## Recommended Order

1. `01_create_lifecycle_repository.sql`
2. `03_create_snapshot_procedures.sql`
3. `04_capture_snapshot_now.sql`
4. `05_create_index_lifecycle_views.sql` through `08_create_action_advisory_views.sql`
5. `09_scheduler_runbook.sql` for optional recurring capture through MySQL Events
6. `10_monthly_capacity_report.sql` for reporting

MySQL does not support database-level DDL triggers, so lifecycle DDL tracking should use audit logs, binary logs, or scheduled snapshots.
