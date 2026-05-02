# 30_backup_restore_pitr_dr

RMAN, archivelog, restore point, PITR, and Data Guard evidence.

Scripts in this area: `9`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @30_backup_restore_pitr_dr/<script>.sql`.

## Scripts

- `01_backup_pitr_configuration_health.sql`
- `02_archivelog_gap_and_lag.sql`
- `03_restore_to_timestamp_quick_test.sql`
- `04_dr_rto_rpo_replication_evidence.sql`
- `05_backup_restore_evidence_contract.sql`
- `06_rman_backup_job_history.sql`
- `07_recovery_area_pressure.sql`
- `08_restore_point_inventory.sql`
- `09_unrecoverable_operations.sql`
