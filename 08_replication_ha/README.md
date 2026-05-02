# 08_replication_ha

Data Guard, archivelog, redo generation, standby apply, and high availability posture.

Scripts in this area: `10`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @08_replication_ha/<script>.sql`.

## Scripts

- `01_primary_replication_status.sql`
- `02_standby_replay_status.sql`
- `03_replication_slots_health.sql`
- `04_redo_generation_rate.sql`
- `05_archivelog_growth_daily.sql`
- `06_archivelog_growth_hourly.sql`
- `07_fra_usage_by_file_type.sql`
- `08_archivelog_backup_delete_readiness.sql`
- `09_data_guard_lag_dashboard.sql`
- `10_archive_dest_error_status.sql`
