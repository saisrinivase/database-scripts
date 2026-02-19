# Consistency and Integrity Checks

Purpose: Early-warning SQL checks for invalid objects, checksum issues, catalog/TOAST anomalies, and integrity verification readiness.

## Run Order

1. `01_invalid_indexes_and_constraints.sql`
2. `02_checksum_status_and_failures.sql`
3. `03_toast_catalog_consistency_signals.sql`
4. `04_amcheck_readiness_and_candidate_commands.sql`
5. `05_xid_visibility_integrity_risk.sql`

## Notes

- These are low-impact diagnostics; they do not repair corruption.
- Any positive signal should trigger controlled deep checks and incident handling.
