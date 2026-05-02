# 26_physical_cloud_diagnostics

Platform fingerprint, storage, wait, checkpoint, and cloud signals.

Scripts in this area: `4`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 26_physical_cloud_diagnostics/<script>.sql`.

## Scripts

- `01_instance_platform_fingerprint.sql`
- `02_io_latency_profile.sql`
- `03_checkpoint_fsync_pressure.sql`
- `04_binlog_retention_risk.sql`
