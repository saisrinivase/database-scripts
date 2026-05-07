/*
PostgreSQL DBA Script: Observer Scheduler Runbook
Purpose: Provide scheduler commands and operating guidance for running the observer-agent scripts continuously.
Area: Observer Agent Monitoring
Usage: Run to print recommended scheduling patterns for cron, pg_cron, and incident-response workflows.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only runbook returned as SQL rows; review paths, database names, and retention policy before use.
*/
SELECT *
FROM (VALUES
    (1, 'setup_once', 'psql -d <database> -f 39_observer_agent_monitoring/01_create_observer_repository.sql', 'Create repository tables.'),
    (2, 'every_1_to_5_minutes', 'psql -d <database> -f 39_observer_agent_monitoring/02_capture_observer_snapshot.sql', 'Capture observer metrics and findings.'),
    (3, 'incident_start', 'psql -d <database> -f 39_observer_agent_monitoring/04_active_incident_detector.sql', 'Detect live incidents without waiting for stored history.'),
    (4, 'incident_classify', 'psql -d <database> -f 39_observer_agent_monitoring/05_wait_lock_io_wal_classifier.sql', 'Classify dominant pressure domain.'),
    (5, 'incident_actions', 'psql -d <database> -f 39_observer_agent_monitoring/06_top_root_cause_action_queue.sql', 'Prioritize DBA actions and next scripts.'),
    (6, 'daily_review', 'psql -d <database> -f 39_observer_agent_monitoring/03_health_score_dashboard.sql', 'Review latest health score and findings.'),
    (7, 'daily_baseline', 'psql -d <database> -f 39_observer_agent_monitoring/07_baseline_deviation_report.sql', 'Compare latest snapshot with previous snapshot.'),
    (8, 'sla_review', 'psql -d <database> -f 39_observer_agent_monitoring/08_sla_risk_dashboard.sql', 'Summarize service-level risk posture.'),
    (9, 'summary', 'psql -d <database> -f 39_observer_agent_monitoring/09_generate_agent_summary.sql', 'Generate a concise human-readable observer summary.'),
    (10, 'pg_cron_guidance', 'Use external cron for psql file execution, or wrap the capture SQL in a reviewed stored procedure before scheduling with pg_cron.', 'pg_cron runs SQL inside the database; it does not run shell psql commands.'),
    (11, 'retention_example', 'DELETE FROM dba_observer.observer_snapshots WHERE captured_at < now() - interval ''90 days'';', 'Use a retention job if snapshots are captured frequently.')
) AS runbook(step_no, schedule_type, command_or_sql, purpose)
ORDER BY step_no;

-- SAMPLE_OUTPUT_BEGIN
-- step_no | schedule_type       | command_or_sql                                                            | purpose
-- --------+---------------------+---------------------------------------------------------------------------+---------------------------------------
--       1 | setup_once          | psql -d <database> -f 39_observer_agent_monitoring/01_create_observer...  | Create repository tables.
--       2 | every_1_to_5_minutes| psql -d <database> -f 39_observer_agent_monitoring/02_capture_observer... | Capture observer metrics and findings.
-- SAMPLE_OUTPUT_END
