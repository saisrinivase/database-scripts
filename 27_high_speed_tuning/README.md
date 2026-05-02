# 27_high_speed_tuning

Fast triage dashboards, wait detail, missing indexes, and action queues.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 27_high_speed_tuning/<script>.sql`.

## Scripts

- `01_bottleneck_overview_dashboard.sql`
- `02_waits_and_blocking_details.sql`
- `03_missing_index_candidates_from_scan_pressure.sql`
- `04_missing_fk_index_candidates.sql`
- `05_parameter_tuning_advisor.sql`
- `06_query_tuning_action_queue.sql`
