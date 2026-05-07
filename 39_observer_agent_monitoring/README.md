# 39_observer_agent_monitoring

Observer-agent monitoring layer for PostgreSQL performance and operations.

Scripts in this area: `10`.

## Usage

Run the repository setup once, then capture snapshots on a schedule:

```bash
psql -d <database> -f 39_observer_agent_monitoring/01_create_observer_repository.sql
psql -d <database> -f 39_observer_agent_monitoring/02_capture_observer_snapshot.sql
psql -d <database> -f 39_observer_agent_monitoring/03_health_score_dashboard.sql
```

## Scripts

- `01_create_observer_repository.sql`
- `02_capture_observer_snapshot.sql`
- `03_health_score_dashboard.sql`
- `04_active_incident_detector.sql`
- `05_wait_lock_io_wal_classifier.sql`
- `06_top_root_cause_action_queue.sql`
- `07_baseline_deviation_report.sql`
- `08_sla_risk_dashboard.sql`
- `09_generate_agent_summary.sql`
- `10_observer_scheduler_runbook.sql`

## Notes

- This pack turns the diagnostic library into an observer workflow: capture, score, detect, classify, route, and summarize.
- The observer repository stores database-visible metrics only. Host/cloud-only metrics still require CloudWatch, OS tools, or provider APIs.
- The scripts are designed for PostgreSQL 15-18 and use portable SQL unless noted in the script header.
