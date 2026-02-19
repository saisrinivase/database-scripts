# Cloud Provider Signals (Optional)

Purpose: Optional checks for managed PostgreSQL environments to capture provider-specific failure domains and drift signals.

## Run Order

1. `01_managed_service_fingerprint.sql`
2. `02_parameter_pending_restart_drift.sql`
3. `03_replica_lag_failover_signals.sql`
4. `04_storage_iops_temp_wal_pressure.sql`
5. `05_cloud_incident_window_checklist.sql`

## Notes

- These scripts are portable SQL-first diagnostics.
- For full incident context, combine with provider consoles (RDS/Aurora, Cloud SQL/AlloyDB, etc.).
