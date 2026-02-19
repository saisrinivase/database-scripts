# Backup, Restore, PITR, and DR Readiness

Purpose: Operational SQL checks for backup/PITR/DR posture, evidence gaps, and quick restore-readiness decisions.

## Run Order

1. `01_backup_pitr_configuration_health.sql`
2. `02_wal_archiving_gap_and_lag.sql`
3. `03_restore_to_timestamp_quick_test.sql`
4. `04_dr_rto_rpo_replication_evidence.sql`
5. `05_backup_restore_evidence_contract.sql`

## Notes

- PostgreSQL catalog views can validate PITR prerequisites, archiving behavior, and replication evidence.
- Last successful base-backup/restore duration usually comes from backup tooling; script `05` checks for an in-database evidence contract.
- Scripts are read-only diagnostics.
