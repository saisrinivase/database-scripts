/*
PostgreSQL DBA Script: Query Text Capture Limits
Purpose: Detect server settings, privileges, and rows that can make SQL text appear truncated or hidden in PostgreSQL diagnostics.
Area: Internals Deep Dive
Usage: Run in pgAdmin Query Tool or psql on PostgreSQL 15+. Review before assuming a display tool or repository script shortened SQL.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for representative result shapes.
Notes: Read-only. A query already truncated by PostgreSQL cannot be reconstructed from pg_stat_activity.
*/

-- Result 1: capture and logging settings that control available SQL evidence.
SELECT
    name,
    setting,
    unit,
    context,
    source,
    pending_restart,
    CASE name
        WHEN 'track_activity_query_size' THEN 'Maximum bytes retained for each pg_stat_activity query. A change requires restart.'
        WHEN 'compute_query_id' THEN 'Controls query identifier calculation for cross-view correlation.'
        WHEN 'track_activities' THEN 'Controls collection of current command and activity start time.'
        WHEN 'log_min_duration_statement' THEN 'Can preserve complete slow-statement evidence in server logs, subject to log collection.'
        WHEN 'log_statement' THEN 'Controls statement logging; broad logging has performance and sensitive-data implications.'
        WHEN 'log_parameter_max_length' THEN 'Limits bind-parameter values logged with non-error statements.'
        WHEN 'log_parameter_max_length_on_error' THEN 'Limits bind-parameter values logged when an error occurs.'
        ELSE 'Query evidence setting.'
    END AS purpose,
    CASE
        WHEN name = 'track_activity_query_size'
         AND pg_size_bytes(setting || coalesce(unit, '')) < 4096
            THEN 'REVIEW: less than 4 KB can truncate long SQL in pg_stat_activity.'
        WHEN name = 'track_activities' AND setting <> 'on'
            THEN 'CRITICAL: current query activity collection is disabled.'
        WHEN name = 'compute_query_id' AND setting = 'off'
            THEN 'REVIEW: query_id correlation is disabled unless an extension supplies identifiers.'
        ELSE 'No generic warning. Validate against security, workload, and provider policy.'
    END AS diagnosis
FROM pg_settings
WHERE name IN (
    'track_activity_query_size',
    'track_activities',
    'compute_query_id',
    'log_min_duration_statement',
    'log_statement',
    'log_parameter_max_length',
    'log_parameter_max_length_on_error'
)
ORDER BY name;

-- Result 2: current rows at or near the server capture limit.
WITH limits AS (
    SELECT pg_size_bytes(current_setting('track_activity_query_size'))::integer AS capture_limit_bytes
)
SELECT
    a.pid,
    a.usename,
    a.datname,
    a.application_name,
    a.state,
    a.query_id,
    octet_length(a.query) AS captured_query_bytes,
    l.capture_limit_bytes,
    round(100.0 * octet_length(a.query) / NULLIF(l.capture_limit_bytes, 0), 2) AS capture_limit_pct,
    a.query AS complete_captured_query_text,
    CASE
        WHEN a.query = '<insufficient privilege>' THEN 'HIDDEN: current role cannot see this backend SQL.'
        WHEN octet_length(a.query) >= l.capture_limit_bytes - 1 THEN 'POSSIBLY_TRUNCATED: captured text reached the configured byte limit.'
        ELSE 'Captured text is below the configured pg_stat_activity limit.'
    END AS diagnosis,
    CASE
        WHEN a.query = '<insufficient privilege>' THEN 'Request pg_read_all_stats or pg_monitor only if least-privilege policy permits.'
        WHEN octet_length(a.query) >= l.capture_limit_bytes - 1 THEN 'Increase track_activity_query_size through the approved parameter workflow and restart; use logs or pg_stat_statements for historical evidence.'
        ELSE 'No pg_stat_activity capture-limit action indicated for this row.'
    END AS recommended_action
FROM pg_stat_activity a
CROSS JOIN limits l
WHERE a.pid <> pg_backend_pid()
ORDER BY capture_limit_pct DESC NULLS LAST, a.pid;

-- Result 3: pg_stat_statements capture readiness without requiring the extension to be installed.
WITH extension_state AS (
    SELECT
        EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') AS installed,
        EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_stat_statements') AS available,
        current_setting('shared_preload_libraries', true) AS shared_preload_libraries
)
SELECT
    installed,
    available,
    shared_preload_libraries,
    current_setting('compute_query_id') AS compute_query_id,
    CASE
        WHEN installed THEN 'PASS: pg_stat_statements is installed; complete text visibility still depends on role privileges.'
        WHEN available AND position('pg_stat_statements' IN coalesce(shared_preload_libraries, '')) > 0
            THEN 'READY: library is preloaded; extension can be created through an approved change.'
        WHEN available THEN 'NOT_READY: extension is available but may require shared_preload_libraries and restart.'
        ELSE 'UNAVAILABLE: use provider-supported query monitoring or PostgreSQL logs.'
    END AS diagnosis
FROM extension_state;

-- SAMPLE_OUTPUT_BEGIN
-- Result 1: track_activity_query_size | 1024 | B | postmaster | REVIEW: less than 4 KB...
-- Result 2: pid | captured_query_bytes | capture_limit_bytes | complete_captured_query_text | diagnosis
-- Result 3: installed | available | shared_preload_libraries | compute_query_id | diagnosis
-- SAMPLE_OUTPUT_END
