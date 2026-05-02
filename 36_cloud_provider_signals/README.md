# 36_cloud_provider_signals

Managed-service fingerprints, parameter drift, replica lag/failover, and incident-window evidence.

Scripts in this area: `7`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @36_cloud_provider_signals/<script>.sql`.

## Scripts

- `01_managed_service_fingerprint.sql`
- `02_parameter_pending_restart_drift.sql`
- `03_replica_lag_failover_signals.sql`
- `04_storage_iops_temp_redo_pressure.sql`
- `05_cloud_incident_window_checklist.sql`
- `06_managed_backup_restore_signals.sql`
- `07_cloud_capacity_pressure_dashboard.sql`
