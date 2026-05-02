# 07_segment_space_reclaim

Segment space reclaim, stale statistics, undo retention, and Segment Advisor signals.

Scripts in this area: `5`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @07_segment_space_reclaim/<script>.sql`.

## Scripts

- `01_table_space_reclaim_estimate.sql`
- `02_segment_reclaim_candidates.sql`
- `03_undo_retention_risk.sql`
- `04_stale_stats_hotspots.sql`
- `05_segment_advisor_progress.sql`
