# 30_backup_restore_pitr_dr

Binary log, backup, PITR, replica, and disaster recovery evidence.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 30_backup_restore_pitr_dr/<script>.sql`.

## Scripts

- `01_backup_pitr_configuration_health.sql`
- `02_binlog_gap_and_lag.sql`
- `03_restore_to_timestamp_quick_test.sql`
- `04_dr_rto_rpo_replication_evidence.sql`
- `05_backup_restore_evidence_contract.sql`
