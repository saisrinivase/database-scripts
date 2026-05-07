/*
PostgreSQL DBA Script: Create Index Lifecycle Views
Purpose: Create index lifecycle views with inferred last-use timestamp and create/drop event tracking.
Area: Object Lifecycle and Capacity Monitoring
Usage: Requires prior snapshots from dba_metrics.sp_capture_operational_snapshot.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
