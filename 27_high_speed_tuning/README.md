# 27_high_speed_tuning

Fast triage dashboards and action queues for bottleneck diagnosis.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @27_high_speed_tuning/<script>.sql`.

## Scripts

- `01_bottleneck_overview_dashboard.sql`
- `02_waits_and_blocking_details.sql`
- `03_missing_index_candidates_from_scan_pressure.sql`
- `04_missing_fk_index_candidates.sql`
- `05_parameter_tuning_advisor.sql`
- `06_query_tuning_action_queue.sql`
