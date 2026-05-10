/*
PostgreSQL DBA Script: Monthly Capacity Report
Purpose: Produce a monthly DBA report for database growth, object growth, and action queue
         with clear section output, percentages, prerequisites, and next actions.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run monthly after regular snapshots are collected. Safe to run in pgAdmin or psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only report. It creates only temporary report tables in the current session.
*/

CREATE TEMP TABLE IF NOT EXISTS monthly_capacity_prereq_report (
    section_name text,
    object_name text,
    status text,
    purpose text,
    next_action text
);

CREATE TEMP TABLE IF NOT EXISTS monthly_capacity_database_report (
    section_name text,
    month_start date,
    database_name text,
    size_pretty text,
    growth_pretty text,
    growth_pct numeric,
    growth_severity text,
    purpose text,
    next_action text
);

CREATE TEMP TABLE IF NOT EXISTS monthly_capacity_object_report (
    section_name text,
    month_start date,
    schema_name text,
    object_name text,
    object_type text,
    total_size_pretty text,
    growth_pretty text,
    growth_pct numeric,
    growth_severity text,
    purpose text,
    next_action text
);

CREATE TEMP TABLE IF NOT EXISTS monthly_capacity_action_report (
    section_name text,
    finding_type text,
    severity text,
    schema_name text,
    table_name text,
    object_name text,
    metric_size text,
    metric_value numeric,
    lifecycle_status text,
    recommendation text,
    next_action text
);

CREATE TEMP TABLE IF NOT EXISTS monthly_capacity_next_steps (
    section_name text,
    step_order integer,
    task_name text,
    purpose text,
    sql_to_run text
);

TRUNCATE monthly_capacity_prereq_report;
TRUNCATE monthly_capacity_database_report;
TRUNCATE monthly_capacity_object_report;
TRUNCATE monthly_capacity_action_report;
TRUNCATE monthly_capacity_next_steps;

INSERT INTO monthly_capacity_prereq_report
SELECT
    'step_01_prerequisites' AS section_name,
    object_name,
    CASE WHEN exists_flag THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        (
            'dba_metrics.vw_database_growth_monthly',
            to_regclass('dba_metrics.vw_database_growth_monthly') IS NOT NULL,
            'Monthly database size and growth trend source.',
            'If missing, run 37_object_lifecycle_capacity/07_create_growth_views.sql.'
        ),
        (
            'dba_metrics.vw_object_growth_monthly',
            to_regclass('dba_metrics.vw_object_growth_monthly') IS NOT NULL,
            'Monthly table, index, toast, and object growth trend source.',
            'If missing, run 37_object_lifecycle_capacity/07_create_growth_views.sql.'
        ),
        (
            'dba_metrics.vw_capacity_action_queue',
            to_regclass('dba_metrics.vw_capacity_action_queue') IS NOT NULL,
            'Prioritized capacity action queue for growth, unused indexes, and DML pressure.',
            'If missing, run 37_object_lifecycle_capacity/08_create_action_advisory_views.sql.'
        ),
        (
            'dba_metrics.database_size_snap',
            to_regclass('dba_metrics.database_size_snap') IS NOT NULL,
            'Raw database size snapshots feeding monthly database growth.',
            'If missing, run 37_object_lifecycle_capacity/01_create_lifecycle_repository.sql.'
        ),
        (
            'dba_metrics.object_size_snap',
            to_regclass('dba_metrics.object_size_snap') IS NOT NULL,
            'Raw object size snapshots feeding monthly object growth.',
            'If missing, run 37_object_lifecycle_capacity/01_create_lifecycle_repository.sql.'
        )
) AS p(object_name, exists_flag, purpose, next_action)
ORDER BY object_name;

DO $$
BEGIN
    IF to_regclass('dba_metrics.vw_database_growth_monthly') IS NULL THEN
        INSERT INTO monthly_capacity_database_report
        VALUES (
            'step_02_database_growth',
            NULL,
            current_database(),
            NULL,
            NULL,
            NULL,
            'MISSING_VIEW',
            'Database growth view is not available.',
            'Run 37_object_lifecycle_capacity/07_create_growth_views.sql, then rerun this monthly report.'
        );
    ELSE
        EXECUTE $sql$
            INSERT INTO monthly_capacity_database_report
            SELECT
                'step_02_database_growth' AS section_name,
                month_start,
                database_name,
                size_pretty,
                growth_pretty,
                growth_pct,
                CASE
                    WHEN coalesce(growth_pct, 0) >= 25 THEN 'HIGH'
                    WHEN coalesce(growth_pct, 0) >= 10 THEN 'MEDIUM'
                    WHEN growth_pct IS NULL THEN 'BASELINE'
                    ELSE 'LOW'
                END AS growth_severity,
                'Monthly database growth trend. Use this to detect storage run-rate changes.' AS purpose,
                CASE
                    WHEN coalesce(growth_pct, 0) >= 25 THEN 'Review largest growing objects, retention, archive policy, and upcoming storage headroom.'
                    WHEN coalesce(growth_pct, 0) >= 10 THEN 'Monitor next snapshot and compare with object growth to find drivers.'
                    WHEN growth_pct IS NULL THEN 'Baseline month. Need at least two months for growth percentage.'
                    ELSE 'No immediate database-level capacity action from this month.'
                END AS next_action
            FROM dba_metrics.vw_database_growth_monthly
            ORDER BY month_start DESC, database_name
            LIMIT 12
        $sql$;

        IF NOT EXISTS (SELECT 1 FROM monthly_capacity_database_report) THEN
            INSERT INTO monthly_capacity_database_report
            VALUES (
                'step_02_database_growth',
                NULL,
                current_database(),
                NULL,
                NULL,
                NULL,
                'NO_DATA',
                'No database growth rows found.',
                'Run SELECT dba_metrics.sp_capture_operational_snapshot(); on a schedule and rerun after snapshots exist.'
            );
        END IF;
    END IF;
END $$;

DO $$
BEGIN
    IF to_regclass('dba_metrics.vw_object_growth_monthly') IS NULL THEN
        INSERT INTO monthly_capacity_object_report
        VALUES (
            'step_03_top_object_growth',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            'MISSING_VIEW',
            'Object growth view is not available.',
            'Run 37_object_lifecycle_capacity/07_create_growth_views.sql, then rerun this monthly report.'
        );
    ELSE
        EXECUTE $sql$
            INSERT INTO monthly_capacity_object_report
            SELECT
                'step_03_top_object_growth' AS section_name,
                month_start,
                schema_name,
                object_name,
                object_type,
                total_size_pretty,
                growth_pretty,
                growth_pct,
                CASE
                    WHEN coalesce(growth_pct, 0) >= 50 OR coalesce(growth_bytes, 0) >= 5::bigint * 1024 * 1024 * 1024 THEN 'HIGH'
                    WHEN coalesce(growth_pct, 0) >= 20 OR coalesce(growth_bytes, 0) >= 1::bigint * 1024 * 1024 * 1024 THEN 'MEDIUM'
                    WHEN growth_pct IS NULL THEN 'BASELINE'
                    ELSE 'LOW'
                END AS growth_severity,
                'Top growing objects for the month. This identifies the tables, indexes, or toast objects driving capacity.' AS purpose,
                CASE
                    WHEN coalesce(growth_pct, 0) >= 50 OR coalesce(growth_bytes, 0) >= 5::bigint * 1024 * 1024 * 1024 THEN 'High growth: review retention, partitioning, index count, and application load pattern.'
                    WHEN coalesce(growth_pct, 0) >= 20 OR coalesce(growth_bytes, 0) >= 1::bigint * 1024 * 1024 * 1024 THEN 'Medium growth: compare with DML pressure and table/index bloat diagnostics.'
                    WHEN growth_pct IS NULL THEN 'Baseline object month. Need another month to calculate growth percentage.'
                    ELSE 'Low growth from current snapshot history.'
                END AS next_action
            FROM dba_metrics.vw_object_growth_monthly
            WHERE growth_bytes IS NOT NULL
            ORDER BY month_start DESC, growth_bytes DESC NULLS LAST
            LIMIT 30
        $sql$;

        IF NOT EXISTS (SELECT 1 FROM monthly_capacity_object_report) THEN
            INSERT INTO monthly_capacity_object_report
            VALUES (
                'step_03_top_object_growth',
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'NO_DATA',
                'No object growth rows found. Usually this means only one month of snapshots exists.',
                'Keep scheduled snapshots running. Growth needs at least two monthly points.'
            );
        END IF;
    END IF;
END $$;

DO $$
BEGIN
    IF to_regclass('dba_metrics.vw_capacity_action_queue') IS NULL THEN
        INSERT INTO monthly_capacity_action_report
        VALUES (
            'step_04_action_queue',
            'MISSING_VIEW',
            'HIGH',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            'MISSING_VIEW',
            'Capacity action queue view is not available.',
            'Run 37_object_lifecycle_capacity/08_create_action_advisory_views.sql after the lifecycle and growth views exist.'
        );
    ELSE
        EXECUTE $sql$
            INSERT INTO monthly_capacity_action_report
            SELECT
                'step_04_action_queue' AS section_name,
                finding_type,
                severity,
                schema_name,
                table_name,
                object_name,
                pg_size_pretty(metric_bytes) AS metric_size,
                metric_value,
                lifecycle_status,
                recommendation,
                CASE
                    WHEN severity = 'HIGH' THEN 'Prioritize this item in the monthly DBA review and create a tracked remediation task.'
                    WHEN severity = 'MEDIUM' THEN 'Validate trend and schedule follow-up if it repeats next cycle.'
                    ELSE 'Keep for awareness unless it grows or affects performance.'
                END AS next_action
            FROM dba_metrics.vw_capacity_action_queue
            ORDER BY
                CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
                metric_bytes DESC NULLS LAST,
                metric_value DESC NULLS LAST
            LIMIT 40
        $sql$;

        IF NOT EXISTS (SELECT 1 FROM monthly_capacity_action_report) THEN
            INSERT INTO monthly_capacity_action_report
            VALUES (
                'step_04_action_queue',
                'NO_FINDINGS',
                'INFO',
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'NO_ACTION',
                'No capacity action queue findings matched the current thresholds.',
                'Continue scheduled snapshots and review growth trends monthly.'
            );
        END IF;
    END IF;
END $$;

INSERT INTO monthly_capacity_next_steps
VALUES
    (
        'step_05_next_steps',
        1,
        'capture_snapshot_now',
        'Refresh raw capacity data before comparing current state.',
        'SELECT dba_metrics.sp_capture_operational_snapshot();'
    ),
    (
        'step_05_next_steps',
        2,
        'database_growth_history',
        'Review the last 12 monthly database growth points.',
        'SELECT * FROM dba_metrics.vw_database_growth_monthly ORDER BY month_start DESC LIMIT 12;'
    ),
    (
        'step_05_next_steps',
        3,
        'largest_object_growth',
        'Find objects driving this month storage increase.',
        'SELECT * FROM dba_metrics.vw_object_growth_monthly WHERE growth_bytes IS NOT NULL ORDER BY month_start DESC, growth_bytes DESC NULLS LAST LIMIT 30;'
    ),
    (
        'step_05_next_steps',
        4,
        'capacity_action_queue',
        'Open the prioritized remediation list.',
        'SELECT * FROM dba_metrics.vw_capacity_action_queue LIMIT 40;'
    );

SELECT
    section_name,
    object_name,
    status,
    purpose,
    next_action
FROM monthly_capacity_prereq_report
ORDER BY object_name;

SELECT
    section_name,
    month_start,
    database_name,
    size_pretty,
    growth_pretty,
    growth_pct,
    growth_severity,
    purpose,
    next_action
FROM monthly_capacity_database_report
ORDER BY month_start DESC NULLS LAST, database_name;

SELECT
    section_name,
    month_start,
    schema_name,
    object_name,
    object_type,
    total_size_pretty,
    growth_pretty,
    growth_pct,
    growth_severity,
    purpose,
    next_action
FROM monthly_capacity_object_report
ORDER BY month_start DESC NULLS LAST, growth_severity, object_name NULLS LAST;

SELECT
    section_name,
    finding_type,
    severity,
    schema_name,
    table_name,
    object_name,
    metric_size,
    metric_value,
    lifecycle_status,
    recommendation,
    next_action
FROM monthly_capacity_action_report
ORDER BY
    CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END,
    finding_type,
    object_name NULLS LAST;

SELECT
    section_name,
    step_order,
    task_name,
    purpose,
    sql_to_run
FROM monthly_capacity_next_steps
ORDER BY step_order;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
--
-- section_name          | object_name                             | status | purpose
-- ----------------------+-----------------------------------------+--------+---------------------------------------------
-- step_01_prerequisites | dba_metrics.vw_database_growth_monthly  | READY  | Monthly database size and growth trend source.
-- step_01_prerequisites | dba_metrics.vw_object_growth_monthly    | READY  | Monthly table, index, toast, and object growth trend source.
--
-- section_name            | month_start | database_name | size_pretty | growth_pretty | growth_pct | growth_severity | next_action
-- ------------------------+-------------+---------------+-------------+---------------+------------+-----------------+------------------------------
-- step_02_database_growth | 2026-02-01  | pgbench_test  | 35 GB       | 3 GB          |       9.37 | LOW             | No immediate database-level capacity action...
--
-- section_name              | month_start | schema_name | object_name | object_type | total_size_pretty | growth_pretty | growth_pct | growth_severity
-- --------------------------+-------------+-------------+-------------+-------------+-------------------+---------------+------------+----------------
-- step_03_top_object_growth | 2026-02-01  | public      | orders      | table       | 12 GB             | 2 GB          |      20.00 | MEDIUM
--
-- section_name         | finding_type        | severity | object_name | metric_size | lifecycle_status | recommendation
-- ---------------------+---------------------+----------+-------------+-------------+------------------+------------------------------
-- step_04_action_queue | FAST_GROWING_OBJECT | MEDIUM   | orders      | 2 GB        | MONTHLY_GROWTH   | Review retention, compression strategy...
--
-- section_name       | step_order | task_name              | sql_to_run
-- -------------------+------------+------------------------+------------------------------
-- step_05_next_steps |          1 | capture_snapshot_now   | SELECT dba_metrics.sp_capture_operational_snapshot();
-- SAMPLE_OUTPUT_END
