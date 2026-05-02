# 07_table_fragmentation_reclaim

Fragmentation estimates, OPTIMIZE candidates, purge pressure, and stale statistics.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 07_table_fragmentation_reclaim/<script>.sql`.

## Scripts

- `01_table_fragmentation_estimate.sql`
- `02_optimize_table_candidates.sql`
- `03_transaction_history_pressure.sql`
- `04_stale_stats_hotspots.sql`
- `05_online_ddl_progress.sql`
