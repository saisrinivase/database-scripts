/*
Purpose: Provide cloud incident-window checklist prompts mapped to likely provider consoles.
Area: Cloud Provider Signals
Usage: Run during incidents to align DB evidence with cloud control-plane events.
*/
WITH provider AS (
    SELECT
        CASE
            WHEN lower(version()) LIKE '%aurora%' OR lower(version()) LIKE '%rds%' THEN 'AWS_RDS_OR_AURORA'
            WHEN lower(version()) LIKE '%cloud sql%' THEN 'GCP_CLOUD_SQL'
            WHEN lower(version()) LIKE '%alloydb%' THEN 'GCP_ALLOYDB'
            WHEN lower(version()) LIKE '%azure%' THEN 'AZURE_DATABASE_FOR_POSTGRESQL'
            ELSE 'SELF_MANAGED_OR_UNKNOWN'
        END AS provider_guess
)
SELECT
    p.provider_guess,
    c.step_no,
    c.check_name,
    c.why_it_matters,
    c.where_to_check
FROM provider p
CROSS JOIN (
    VALUES
        (1, 'Failover/restart history', 'Explains sudden latency spikes, connection resets, and role changes.', 'Provider event timeline / activity stream'),
        (2, 'Parameter group or flag changes', 'Confirms whether runtime drift came from control-plane updates.', 'Parameter group / flags history'),
        (3, 'Storage scaling and IOPS credits', 'Correlates IO waits and temp spill pain with storage constraints.', 'Storage metrics dashboard (IOPS, throughput, burst balance)'),
        (4, 'Network/proxy health', 'Captures transient connectivity, TLS, or proxy queue issues.', 'Network/proxy error metrics and connection charts'),
        (5, 'Replica lag and maintenance events', 'Separates query pressure from replication or maintenance side-effects.', 'Replica lag charts, maintenance operation logs')
) AS c(step_no, check_name, why_it_matters, where_to_check)
ORDER BY c.step_no;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--      provider_guess      | step_no |             check_name             |                             why_it_matters                             |                       where_to_check                        
-- -------------------------+---------+------------------------------------+------------------------------------------------------------------------+-------------------------------------------------------------
--  SELF_MANAGED_OR_UNKNOWN |       1 | Failover/restart history           | Explains sudden latency spikes, connection resets, and role changes.   | Provider event timeline / activity stream
--  SELF_MANAGED_OR_UNKNOWN |       2 | Parameter group or flag changes    | Confirms whether runtime drift came from control-plane updates.        | Parameter group / flags history
--  SELF_MANAGED_OR_UNKNOWN |       3 | Storage scaling and IOPS credits   | Correlates IO waits and temp spill pain with storage constraints.      | Storage metrics dashboard (IOPS, throughput, burst balance)
--  SELF_MANAGED_OR_UNKNOWN |       4 | Network/proxy health               | Captures transient connectivity, TLS, or proxy queue issues.           | Network/proxy error metrics and connection charts
--  SELF_MANAGED_OR_UNKNOWN |       5 | Replica lag and maintenance events | Separates query pressure from replication or maintenance side-effects. | Replica lag charts, maintenance operation logs
-- (5 rows)
-- 
-- SAMPLE_OUTPUT_END
