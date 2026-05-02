# 12_planner_statistics

Optimizer statistics quality, stale objects, histogram and extension inventory, and optimizer parameters.

Scripts in this area: `10`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @12_planner_statistics/<script>.sql`.

## Scripts

- `01_tables_needing_analyze.sql`
- `02_seq_scan_hotspots.sql`
- `03_column_stats_profile.sql`
- `04_extended_stats_candidates.sql`
- `05_stats_gathering_settings_by_table.sql`
- `06_planner_cost_settings.sql`
- `07_stale_stats_by_schema.sql`
- `08_histogram_skew_inventory.sql`
- `09_sql_plan_directives_inventory.sql`
- `10_locked_stats_inventory.sql`
