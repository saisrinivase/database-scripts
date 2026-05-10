/*
PostgreSQL DBA Script: Create Index Lifecycle Views
Purpose: Create index lifecycle views with inferred last-use timestamp, create/drop event tracking,
         and step-by-step readiness/output checks for pgAdmin or psql users.
Area: Object Lifecycle and Capacity Monitoring
Usage: Best after 01_create_lifecycle_repository.sql, 02_create_ddl_event_triggers.sql,
       and at least one dba_metrics.sp_capture_operational_snapshot execution.
       The required repository tables are created when missing so the script can run standalone.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Creates or replaces reporting views, then prints validation, preview, and next-query output.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

SELECT
    'step_01_schema' AS setup_step,
    'dba_metrics' AS object_name,
    CASE
        WHEN to_regnamespace('dba_metrics') IS NOT NULL THEN 'READY'
        ELSE 'FAILED'
    END AS status,
    'Schema exists for lifecycle repository objects.' AS output_description,
    'Continue only when status is READY.' AS next_action;

CREATE TABLE IF NOT EXISTS dba_metrics.capture_run (
    run_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    captured_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    database_name text NOT NULL DEFAULT current_database(),
    capture_source text NOT NULL DEFAULT 'manual',
    notes text
);

CREATE TABLE IF NOT EXISTS dba_metrics.ddl_event_log (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_ts timestamptz NOT NULL DEFAULT clock_timestamp(),
    event_kind text NOT NULL,
    command_tag text,
    object_type text,
    schema_name text,
    object_identity text,
    in_extension boolean,
    username text NOT NULL DEFAULT session_user,
    txid bigint,
    details jsonb
);

CREATE TABLE IF NOT EXISTS dba_metrics.index_usage_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    stats_reset timestamptz,
    index_oid oid NOT NULL,
    table_oid oid NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    index_name text NOT NULL,
    idx_scan bigint NOT NULL,
    idx_tup_read bigint NOT NULL,
    idx_tup_fetch bigint NOT NULL,
    index_size_bytes bigint NOT NULL,
    table_total_size_bytes bigint NOT NULL,
    is_unique boolean,
    is_primary boolean,
    is_valid boolean,
    is_ready boolean,
    is_live boolean,
    constraint_name text,
    PRIMARY KEY (run_id, index_oid)
);

SELECT
    'step_01a_repository_prerequisites' AS setup_step,
    dependency_name AS object_name,
    CASE WHEN exists_flag THEN 'READY' ELSE 'MISSING' END AS status,
    output_description,
    next_action
FROM (
    VALUES
        (
            'dba_metrics.capture_run',
            to_regclass('dba_metrics.capture_run') IS NOT NULL,
            'Repository table for each snapshot run.',
            'Created by this script if missing.'
        ),
        (
            'dba_metrics.index_usage_snap',
            to_regclass('dba_metrics.index_usage_snap') IS NOT NULL,
            'Repository table containing index usage snapshots.',
            'Populate with SELECT dba_metrics.sp_capture_operational_snapshot();'
        ),
        (
            'dba_metrics.ddl_event_log',
            to_regclass('dba_metrics.ddl_event_log') IS NOT NULL,
            'Repository table containing index create/drop events.',
            'Enable event triggers with 02_create_ddl_event_triggers.sql for full create/drop history.'
        )
) AS d(dependency_name, exists_flag, output_description, next_action)
ORDER BY object_name;

CREATE OR REPLACE VIEW dba_metrics.vw_index_usage_delta AS
WITH ordered AS (
    SELECT
        s.*,
        lag(s.idx_scan) OVER (
            PARTITION BY s.index_oid
            ORDER BY s.captured_at
        ) AS prev_idx_scan,
        lag(s.stats_reset) OVER (
            PARTITION BY s.index_oid
            ORDER BY s.captured_at
        ) AS prev_stats_reset
    FROM dba_metrics.index_usage_snap s
)
SELECT
    run_id,
    captured_at,
    database_name,
    stats_reset,
    index_oid,
    table_oid,
    schema_name,
    table_name,
    index_name,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    index_size_bytes,
    table_total_size_bytes,
    is_unique,
    is_primary,
    is_valid,
    is_ready,
    is_live,
    constraint_name,
    CASE
        WHEN prev_idx_scan IS NULL THEN NULL
        WHEN prev_stats_reset IS DISTINCT FROM stats_reset THEN NULL
        WHEN idx_scan < prev_idx_scan THEN NULL
        ELSE idx_scan - prev_idx_scan
    END AS delta_idx_scan,
    lower(replace(format('%I.%I', schema_name, index_name), '"', '')) AS object_key
FROM ordered;

SELECT
    'step_02_view' AS setup_step,
    'dba_metrics.vw_index_usage_delta' AS object_name,
    CASE
        WHEN to_regclass('dba_metrics.vw_index_usage_delta') IS NOT NULL THEN 'READY'
        ELSE 'FAILED'
    END AS status,
    'Shows per-snapshot index scan deltas. A positive delta_idx_scan means the index was used between snapshots.' AS output_description,
    'Example: SELECT * FROM dba_metrics.vw_index_usage_delta ORDER BY captured_at DESC, delta_idx_scan DESC NULLS LAST LIMIT 20;' AS next_action;

SELECT
    'step_02a_usage_delta_row_count' AS setup_step,
    'dba_metrics.vw_index_usage_delta' AS object_name,
    count(*)::text AS output_value,
    'Rows available in the delta view. Zero means snapshots have not been captured yet.' AS output_description,
    'If zero, run SELECT dba_metrics.sp_capture_operational_snapshot(); at least twice with workload between captures.' AS next_action
FROM dba_metrics.vw_index_usage_delta;

SELECT
    'step_02b_usage_delta_latest_capture' AS setup_step,
    'dba_metrics.vw_index_usage_delta' AS object_name,
    coalesce(max(captured_at)::text, 'NO_ROWS') AS output_value,
    'Latest snapshot timestamp visible to the delta view.' AS output_description,
    'Fresh captures make stale or unused index decisions safer.' AS next_action
FROM dba_metrics.vw_index_usage_delta;

CREATE OR REPLACE VIEW dba_metrics.vw_index_lifecycle AS
WITH snap_base AS (
    SELECT
        lower(replace(format('%I.%I', schema_name, index_name), '"', '')) AS object_key,
        *
    FROM dba_metrics.index_usage_snap
),
latest AS (
    SELECT DISTINCT ON (object_key)
        object_key,
        index_oid,
        schema_name,
        table_name,
        index_name,
        idx_scan AS current_idx_scan,
        index_size_bytes AS current_index_size_bytes,
        captured_at AS last_seen_at,
        is_unique,
        is_primary,
        is_valid,
        is_ready,
        is_live,
        constraint_name
    FROM snap_base
    ORDER BY object_key, captured_at DESC
),
first_seen AS (
    SELECT
        object_key,
        min(captured_at) AS first_seen_at
    FROM snap_base
    GROUP BY object_key
),
last_scan AS (
    SELECT
        object_key,
        max(captured_at) AS last_scan_at
    FROM dba_metrics.vw_index_usage_delta
    WHERE coalesce(delta_idx_scan, 0) > 0
    GROUP BY object_key
),
created_evt AS (
    SELECT
        lower(
            regexp_replace(
                replace(object_identity, '"', ''),
                '\s+on\s+.*$',
                ''
            )
        ) AS object_key,
        max(event_ts) AS created_at
    FROM dba_metrics.ddl_event_log
    WHERE event_kind = 'ddl_command_end'
      AND object_type ILIKE '%index%'
      AND coalesce(command_tag, '') !~* '^DROP'
    GROUP BY lower(
        regexp_replace(
            replace(object_identity, '"', ''),
            '\s+on\s+.*$',
            ''
        )
    )
),
dropped_evt AS (
    SELECT
        lower(
            regexp_replace(
                replace(object_identity, '"', ''),
                '\s+on\s+.*$',
                ''
            )
        ) AS object_key,
        max(event_ts) AS dropped_at
    FROM dba_metrics.ddl_event_log
    WHERE event_kind = 'sql_drop'
      AND object_type ILIKE '%index%'
    GROUP BY lower(
        regexp_replace(
            replace(object_identity, '"', ''),
            '\s+on\s+.*$',
            ''
        )
    )
),
all_keys AS (
    SELECT object_key FROM latest
    UNION
    SELECT object_key FROM created_evt
    UNION
    SELECT object_key FROM dropped_evt
)
SELECT
    coalesce(l.schema_name, nullif(split_part(k.object_key, '.', 1), '')) AS schema_name,
    l.table_name,
    coalesce(l.index_name, nullif(split_part(k.object_key, '.', 2), '')) AS index_name,
    pg_size_pretty(l.current_index_size_bytes) AS current_index_size_pretty,
    l.current_index_size_bytes,
    l.current_idx_scan,
    f.first_seen_at,
    c.created_at,
    ls.last_scan_at,
    l.last_seen_at,
    CASE
        WHEN d.dropped_at IS NOT NULL
             AND (c.created_at IS NULL OR d.dropped_at > c.created_at)
            THEN d.dropped_at
        ELSE NULL
    END AS dropped_at,
    CASE
        WHEN d.dropped_at IS NOT NULL
             AND (c.created_at IS NULL OR d.dropped_at > c.created_at)
             AND l.object_key IS NULL THEN 'DROPPED'
        WHEN d.dropped_at IS NOT NULL
             AND (c.created_at IS NULL OR d.dropped_at > c.created_at) THEN 'DROPPED_EVENT_PRESENT'
        WHEN l.object_key IS NULL THEN 'EVENT_ONLY'
        WHEN l.current_idx_scan = 0 AND clock_timestamp() - f.first_seen_at > interval '30 days' THEN 'NEVER_USED_30D'
        WHEN ls.last_scan_at IS NULL THEN 'NO_SCAN_DELTA_YET'
        WHEN clock_timestamp() - ls.last_scan_at > interval '30 days' THEN 'STALE_30D'
        ELSE 'ACTIVE'
    END AS lifecycle_status,
    CASE
        WHEN d.dropped_at IS NOT NULL
             AND (c.created_at IS NULL OR d.dropped_at > c.created_at)
             AND l.object_key IS NULL THEN 'Dropped index captured in DDL log.'
        WHEN d.dropped_at IS NOT NULL
             AND (c.created_at IS NULL OR d.dropped_at > c.created_at) THEN 'Drop event exists for index name currently present; review event history.'
        WHEN l.object_key IS NULL THEN 'Index exists only in DDL event log; no snapshot row found.'
        WHEN coalesce(l.is_primary, false) THEN 'Protected: primary key index. Do not drop.'
        WHEN coalesce(l.constraint_name, '') <> '' THEN 'Protected: backs a constraint. Do not drop.'
        WHEN coalesce(l.is_unique, false) THEN 'Protected by policy: unique index is excluded from drop automation.'
        WHEN coalesce(l.is_valid, true) = false
          OR coalesce(l.is_ready, true) = false
          OR coalesce(l.is_live, true) = false THEN 'Index state is not fully healthy; investigate before any lifecycle action.'
        WHEN l.current_idx_scan = 0 AND clock_timestamp() - f.first_seen_at > interval '30 days' THEN 'Candidate for review with EXPLAIN before DROP INDEX.'
        WHEN ls.last_scan_at IS NULL THEN 'Need more snapshots or index has not shown scan increase yet.'
        WHEN clock_timestamp() - ls.last_scan_at > interval '30 days' THEN 'Revalidate usefulness in current workload window.'
        ELSE 'No immediate action.'
    END AS advisory_note,
    l.is_unique,
    l.is_primary,
    l.is_valid,
    l.is_ready,
    l.is_live,
    l.constraint_name,
    CASE
        WHEN f.first_seen_at IS NULL THEN NULL
        ELSE floor(extract(epoch FROM clock_timestamp() - f.first_seen_at) / 86400)::int
    END AS observation_days,
    CASE
        WHEN ls.last_scan_at IS NULL THEN NULL
        ELSE floor(extract(epoch FROM clock_timestamp() - ls.last_scan_at) / 86400)::int
    END AS days_since_last_scan,
    (coalesce(ls.last_scan_at, f.first_seen_at) + interval '45 days') AS eligible_to_drop_after,
    CASE
        WHEN l.object_key IS NULL THEN 'NOT_PRESENT'
        WHEN coalesce(l.is_primary, false) THEN 'BLOCK_PRIMARY'
        WHEN coalesce(l.constraint_name, '') <> '' THEN 'BLOCK_CONSTRAINT'
        WHEN coalesce(l.is_unique, false) THEN 'BLOCK_UNIQUE'
        WHEN coalesce(l.is_valid, true) = false
          OR coalesce(l.is_ready, true) = false
          OR coalesce(l.is_live, true) = false THEN 'REVIEW_INDEX_STATE'
        WHEN coalesce(ls.last_scan_at, f.first_seen_at) IS NULL THEN 'INSUFFICIENT_HISTORY'
        WHEN clock_timestamp() < coalesce(ls.last_scan_at, f.first_seen_at) + interval '45 days' THEN 'HOLD_45D'
        ELSE 'ELIGIBLE_AFTER_REVIEW'
    END AS drop_eligibility_status
FROM all_keys k
LEFT JOIN latest l
  ON l.object_key = k.object_key
LEFT JOIN first_seen f
  ON f.object_key = k.object_key
LEFT JOIN last_scan ls
  ON ls.object_key = k.object_key
LEFT JOIN created_evt c
  ON c.object_key = k.object_key
LEFT JOIN dropped_evt d
  ON d.object_key = k.object_key;

SELECT
    'step_03_view' AS setup_step,
    'dba_metrics.vw_index_lifecycle' AS object_name,
    CASE
        WHEN to_regclass('dba_metrics.vw_index_lifecycle') IS NOT NULL THEN 'READY'
        ELSE 'FAILED'
    END AS status,
    'Combines snapshots and DDL events to show first seen, last scan, drop events, lifecycle status, advisory note, and drop eligibility.' AS output_description,
    'Example: SELECT schema_name, table_name, index_name, lifecycle_status, advisory_note, drop_eligibility_status FROM dba_metrics.vw_index_lifecycle ORDER BY lifecycle_status, current_index_size_bytes DESC NULLS LAST LIMIT 20;' AS next_action;

SELECT
    'step_03a_lifecycle_row_count' AS setup_step,
    'dba_metrics.vw_index_lifecycle' AS object_name,
    count(*)::text AS output_value,
    'Rows available in the lifecycle view. Each row represents a current or event-only index identity.' AS output_description,
    'If zero, capture snapshots and confirm index_usage_snap contains rows for the connected database.' AS next_action
FROM dba_metrics.vw_index_lifecycle;

SELECT
    'step_04_dependency_check' AS setup_step,
    dependency_name AS object_name,
    CASE WHEN exists_flag THEN 'READY' ELSE 'MISSING' END AS status,
    output_description,
    next_action
FROM (
    VALUES
        (
            'dba_metrics.index_usage_snap',
            to_regclass('dba_metrics.index_usage_snap') IS NOT NULL,
            'Required snapshot table used by both lifecycle views.',
            'If missing, run 37_object_lifecycle_capacity/01_create_lifecycle_repository.sql first.'
        ),
        (
            'dba_metrics.ddl_event_log',
            to_regclass('dba_metrics.ddl_event_log') IS NOT NULL,
            'Required DDL event table used to identify create/drop events.',
            'If missing, run repository setup and event trigger setup before relying on create/drop timestamps.'
        ),
        (
            'dba_metrics.vw_index_usage_delta',
            to_regclass('dba_metrics.vw_index_usage_delta') IS NOT NULL,
            'Delta view created by this script.',
            'Use it to confirm scan count movement between operational snapshots.'
        ),
        (
            'dba_metrics.vw_index_lifecycle',
            to_regclass('dba_metrics.vw_index_lifecycle') IS NOT NULL,
            'Lifecycle view created by this script.',
            'Use it to review ACTIVE, STALE_30D, NEVER_USED_30D, DROPPED, and drop eligibility states.'
        )
) AS d(dependency_name, exists_flag, output_description, next_action)
ORDER BY setup_step, object_name;

SELECT
    'step_05_sample_index_lifecycle_output' AS setup_step,
    schema_name,
    table_name,
    index_name,
    current_index_size_pretty,
    current_idx_scan,
    lifecycle_status,
    advisory_note,
    observation_days,
    days_since_last_scan,
    drop_eligibility_status
FROM dba_metrics.vw_index_lifecycle
ORDER BY
    CASE lifecycle_status
        WHEN 'DROPPED' THEN 1
        WHEN 'DROPPED_EVENT_PRESENT' THEN 2
        WHEN 'NEVER_USED_30D' THEN 3
        WHEN 'STALE_30D' THEN 4
        WHEN 'NO_SCAN_DELTA_YET' THEN 5
        ELSE 6
    END,
    current_index_size_bytes DESC NULLS LAST,
    schema_name,
    table_name,
    index_name
LIMIT 20;

WITH summary_rows AS (
    SELECT
        lifecycle_status,
        count(*) AS index_count,
        round(100.0 * count(*) / nullif(sum(count(*)) OVER (), 0), 2) AS pct_of_indexes,
        pg_size_pretty(sum(coalesce(current_index_size_bytes, 0))::bigint) AS total_index_size,
        round(
            100.0 * sum(coalesce(current_index_size_bytes, 0))
            / nullif(sum(sum(coalesce(current_index_size_bytes, 0))) OVER (), 0),
            2
        ) AS pct_of_index_bytes,
        CASE
            WHEN lifecycle_status IN ('NEVER_USED_30D', 'STALE_30D')
                THEN 'Review candidates with EXPLAIN and workload owner before any DROP INDEX.'
            WHEN lifecycle_status IN ('DROPPED', 'DROPPED_EVENT_PRESENT')
                THEN 'Confirm event history and whether object is still present.'
            WHEN lifecycle_status = 'NO_SCAN_DELTA_YET'
                THEN 'Collect more snapshots before making lifecycle decisions.'
            ELSE 'No immediate lifecycle action from this status.'
        END AS recommended_action
    FROM dba_metrics.vw_index_lifecycle
    GROUP BY lifecycle_status
)
SELECT
    'step_06_summary' AS setup_step,
    lifecycle_status,
    index_count,
    pct_of_indexes,
    total_index_size,
    pct_of_index_bytes,
    recommended_action
FROM summary_rows
UNION ALL
SELECT
    'step_06_summary' AS setup_step,
    'NO_DATA' AS lifecycle_status,
    0 AS index_count,
    0.00 AS pct_of_indexes,
    '0 bytes' AS total_index_size,
    0.00 AS pct_of_index_bytes,
    'No lifecycle rows found. Capture snapshots before making index lifecycle decisions.' AS recommended_action
WHERE NOT EXISTS (SELECT 1 FROM summary_rows)
ORDER BY index_count DESC, lifecycle_status;

WITH summary_rows AS (
    SELECT
        drop_eligibility_status,
        count(*) AS index_count,
        round(100.0 * count(*) / nullif(sum(count(*)) OVER (), 0), 2) AS pct_of_indexes,
        pg_size_pretty(sum(coalesce(current_index_size_bytes, 0))::bigint) AS total_index_size,
        CASE
            WHEN drop_eligibility_status = 'ELIGIBLE_AFTER_REVIEW'
                THEN 'Do not drop automatically. Validate with EXPLAIN, dependency checks, backups, and business workload window.'
            WHEN drop_eligibility_status LIKE 'BLOCK_%'
                THEN 'Protected index class. Treat as not eligible for drop.'
            WHEN drop_eligibility_status = 'HOLD_45D'
                THEN 'Observation window is still active. Keep collecting snapshots.'
            WHEN drop_eligibility_status = 'INSUFFICIENT_HISTORY'
                THEN 'Need more lifecycle history before deciding.'
            WHEN drop_eligibility_status = 'REVIEW_INDEX_STATE'
                THEN 'Index validity/readiness/live flags need investigation before lifecycle action.'
            ELSE 'Review context before any change.'
        END AS recommended_action
    FROM dba_metrics.vw_index_lifecycle
    GROUP BY drop_eligibility_status
)
SELECT
    'step_07_drop_eligibility_summary' AS setup_step,
    drop_eligibility_status,
    index_count,
    pct_of_indexes,
    total_index_size,
    recommended_action
FROM summary_rows
UNION ALL
SELECT
    'step_07_drop_eligibility_summary' AS setup_step,
    'NO_DATA' AS drop_eligibility_status,
    0 AS index_count,
    0.00 AS pct_of_indexes,
    '0 bytes' AS total_index_size,
    'No lifecycle rows found. Capture snapshots before deciding whether indexes are eligible for review.' AS recommended_action
WHERE NOT EXISTS (SELECT 1 FROM summary_rows)
ORDER BY index_count DESC, drop_eligibility_status;

SELECT
    'step_08_next_queries' AS setup_step,
    query_name,
    sql_to_run,
    purpose
FROM (
    VALUES
        (
            'largest_review_candidates',
            'SELECT schema_name, table_name, index_name, current_index_size_pretty, current_idx_scan, lifecycle_status, advisory_note, drop_eligibility_status FROM dba_metrics.vw_index_lifecycle WHERE drop_eligibility_status = ''ELIGIBLE_AFTER_REVIEW'' ORDER BY current_index_size_bytes DESC NULLS LAST LIMIT 50;',
            'Shows the largest indexes that may be eligible only after manual workload validation.'
        ),
        (
            'recent_scan_deltas',
            'SELECT captured_at, schema_name, table_name, index_name, idx_scan, delta_idx_scan, pg_size_pretty(index_size_bytes) AS index_size FROM dba_metrics.vw_index_usage_delta ORDER BY captured_at DESC, delta_idx_scan DESC NULLS LAST LIMIT 50;',
            'Shows whether indexes are currently being used between snapshots.'
        ),
        (
            'protected_indexes',
            'SELECT schema_name, table_name, index_name, is_primary, is_unique, constraint_name, drop_eligibility_status FROM dba_metrics.vw_index_lifecycle WHERE drop_eligibility_status LIKE ''BLOCK_%'' ORDER BY schema_name, table_name, index_name;',
            'Shows indexes blocked from drop consideration because they protect constraints, primary keys, or uniqueness.'
        )
) AS q(query_name, sql_to_run, purpose);




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
--
-- setup_step     | object_name                        | status | output_description
-- ---------------+------------------------------------+--------+------------------------------
-- step_01_schema | dba_metrics                        | READY  | Schema exists...
-- step_02_view   | dba_metrics.vw_index_usage_delta   | READY  | Shows per-snapshot index scan deltas...
--
-- setup_step                         | object_name                       | output_value | output_description
-- -----------------------------------+-----------------------------------+--------------+------------------------------
-- step_02a_usage_delta_row_count     | dba_metrics.vw_index_usage_delta  | 1540         | Rows available in the delta view...
-- step_02b_usage_delta_latest_capture| dba_metrics.vw_index_usage_delta  | 2026-02-20...| Latest snapshot timestamp...
--
-- setup_step                    | object_name                     | status | output_description
-- ------------------------------+---------------------------------+--------+------------------------------
-- step_03_view   | dba_metrics.vw_index_lifecycle     | READY  | Combines snapshots and DDL events...
--
-- setup_step                  | object_name                    | output_value | output_description
-- ----------------------------+--------------------------------+--------------+------------------------------
-- step_03a_lifecycle_row_count| dba_metrics.vw_index_lifecycle | 220          | Rows available in the lifecycle view...
--
-- setup_step                    | schema_name | table_name | index_name | lifecycle_status | advisory_note
-- -----------------------------+-------------+------------+------------+------------------+------------------------------
-- step_05_sample_index_lifecycle_output | public | orders | orders_idx | ACTIVE | No immediate action.
--
-- setup_step      | lifecycle_status | index_count | pct_of_indexes | total_index_size | pct_of_index_bytes | recommended_action
-- ----------------+------------------+-------------+----------------+------------------+--------------------+------------------------------
-- step_06_summary | ACTIVE           |          20 |          90.91 | 256 MB           |              94.12 | No immediate lifecycle action...
--
-- setup_step                       | drop_eligibility_status | index_count | pct_of_indexes | total_index_size | recommended_action
-- ---------------------------------+-------------------------+-------------+----------------+------------------+------------------------------
-- step_07_drop_eligibility_summary | HOLD_45D                |          14 |          63.64 | 180 MB           | Observation window is still active...
--
-- setup_step          | query_name                 | sql_to_run | purpose
-- --------------------+----------------------------+------------+------------------------------
-- step_08_next_queries| largest_review_candidates  | SELECT ... | Shows the largest indexes that may be eligible only after manual workload validation.
-- SAMPLE_OUTPUT_END
