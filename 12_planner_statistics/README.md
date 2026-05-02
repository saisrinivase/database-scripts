# 12_planner_statistics

Optimizer statistics quality, stale objects, histogram and extension inventory, and optimizer parameters.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @12_planner_statistics/<script>.sql`.

## Scripts

- `01_tables_needing_analyze.sql`
- `02_seq_scan_hotspots.sql`
- `03_column_stats_profile.sql`
- `04_extended_stats_candidates.sql`
- `05_stats_gathering_settings_by_table.sql`
- `06_planner_cost_settings.sql`
