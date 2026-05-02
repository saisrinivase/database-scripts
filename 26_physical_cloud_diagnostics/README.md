# 26_physical_cloud_diagnostics

Platform fingerprint, storage, wait, checkpoint, and managed-service signals.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @26_physical_cloud_diagnostics/<script>.sql`.

## Scripts

- `01_instance_platform_fingerprint.sql`
- `02_io_latency_profile.sql`
- `03_checkpoint_fsync_pressure.sql`
- `04_archived_redo_retention_risk.sql`
