# 38_observability_360

CloudWatch-style command-line observability for PostgreSQL DBAs.

Scripts in this area: `12`.

## Usage

Run with `psql`, for example:

```bash
psql -d <database> -f 38_observability_360/01_instance_health_360_dashboard.sql
```

## Scripts

- `01_instance_health_360_dashboard.sql`
- `02_cloudwatch_metric_equivalents.sql`
- `03_stat_view_coverage_check.sql`
- `04_wait_event_hotspots.sql`
- `05_database_activity_metrics.sql`
- `06_table_index_activity_heatmap.sql`
- `07_wal_checkpoint_archiver_dashboard.sql`
- `08_autovacuum_vacuum_analyze_progress.sql`
- `09_replication_and_slot_dashboard.sql`
- `10_query_capture_quality_pgss.sql`
- `11_growth_and_capacity_snapshot_now.sql`
- `12_sme_triage_command_router.sql`

## Notes

- PostgreSQL can expose many database-internal metrics through `pg_stat_*`, catalog views, and extensions.
- Host/cloud-only metrics such as CPU utilization, free memory, storage free space, disk queue depth, and network throughput still require CloudWatch, OS tools, or provider APIs.
- Version-specific views are guarded with `psql` conditionals where needed.
