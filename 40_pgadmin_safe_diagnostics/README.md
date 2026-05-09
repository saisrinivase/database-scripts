# 40_pgadmin_safe_diagnostics

Plain-SQL diagnostic pack for pgAdmin Query Tool and other SQL clients.

Scripts in this area: `12`.

## Usage

Open a script in pgAdmin Query Tool and execute it directly. These scripts avoid `psql` meta commands such as `\gset`, `\if`, `\pset`, `\echo`, and `\o`.

## Scripts

- `01_pgadmin_compatibility_audit.sql`
- `02_pgadmin_safe_vacuum_progress.sql`
- `03_pgadmin_safe_checkpoint_bgwriter.sql`
- `04_pgadmin_safe_pg_stat_io_overview.sql`
- `05_pgadmin_safe_pg_stat_statements_quality.sql`
- `06_pgadmin_safe_cloudwatch_metric_equivalents.sql`
- `07_pgadmin_safe_replication_ha_dashboard.sql`
- `08_pgadmin_safe_wal_checkpoint_archiver.sql`
- `09_pgadmin_safe_observer_health_dashboard.sql`
- `10_pgadmin_safe_root_cause_action_queue.sql`
- `11_pgadmin_safe_backup_restore_evidence.sql`
- `12_pgadmin_safe_sme_diagnosis_router.sql`

## Notes

- Some scripts create temporary `pg_temp` helper functions so they can branch safely inside pgAdmin without `psql` conditionals.
- Temporary helper functions are session-local and disappear when the pgAdmin database session ends.
- Host/cloud-only metrics such as CPU, free memory, disk queue depth, network throughput, and filesystem free space still require CloudWatch, OS tools, or provider APIs.
