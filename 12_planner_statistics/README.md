# 12_planner_statistics

Optimizer statistics, full scan hotspots, histograms, and optimizer variables.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 12_planner_statistics/<script>.sql`.

## Scripts

- `01_tables_needing_analyze.sql`
- `02_seq_scan_hotspots.sql`
- `03_column_stats_profile.sql`
- `04_extended_stats_candidates.sql`
- `05_auto_analyze_settings_by_table.sql`
- `06_planner_cost_settings.sql`
