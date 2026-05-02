# 36_cloud_provider_signals

Managed-service fingerprints, variable drift, replica/failover, storage, and incident evidence.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 36_cloud_provider_signals/<script>.sql`.

## Scripts

- `01_managed_service_fingerprint.sql`
- `02_parameter_pending_restart_drift.sql`
- `03_replica_lag_failover_signals.sql`
- `04_storage_iops_temp_binlog_pressure.sql`
- `05_cloud_incident_window_checklist.sql`
