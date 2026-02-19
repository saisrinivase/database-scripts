# Upgrade and Patch Readiness (15 -> 16 -> 17 -> 18)

Purpose: Operational SQL checks for pre-upgrade risks, compatibility drift, and post-upgrade regression watchlists.

## Run Order

1. `01_version_upgrade_path_overview.sql`
2. `02_extension_version_drift_dependencies.sql`
3. `03_preupgrade_invalid_objects_gate.sql`
4. `04_collation_version_mismatch_risk.sql`
5. `05_postupgrade_query_regression_watchlist_pgss.sql`
6. `06_config_file_unknown_or_deprecated_gucs.sql`

## Notes

- This area does not execute upgrade steps; it provides evidence and blockers before change windows.
- Combine with staging rehearsal and `pg_upgrade` or logical migration runbooks.
