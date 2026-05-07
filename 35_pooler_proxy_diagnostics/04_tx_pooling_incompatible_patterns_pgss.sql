/*
PostgreSQL DBA Script: Tx Pooling Incompatible Patterns Pg Stat Statements
Purpose: Identify query patterns that are problematic in transaction pooling modes.
Area: Pooler and Proxy Diagnostics
Usage: Requires pg_stat_statements. Use to detect LISTEN/temp-table/session-state dependencies.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT CASE
           WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 1
           ELSE 0
       END AS has_pgss
\gset

\if :has_pgss
WITH patterns AS (
    SELECT
        queryid,
        calls,
        total_exec_time,
        mean_exec_time,
        CASE
            WHEN query ~* '\\blisten\\b|\\bunlisten\\b' THEN 'LISTEN_UNLISTEN'
            WHEN query ~* '\\bcreate\\s+temp\\b|\\btemporary\\s+table\\b' THEN 'TEMP_TABLE_USAGE'
            WHEN query ~* '\\bset\\s+(session|role|search_path)\\b' THEN 'SESSION_STATE_MUTATION'
            WHEN query ~* '\\bdeclare\\b.*\\bcursor\\b' THEN 'CURSOR_USAGE'
            WHEN query ~* '\\bpg_advisory_lock\\b|\\bpg_try_advisory_lock\\b' THEN 'ADVISORY_LOCK_USAGE'
            ELSE 'OTHER'
        END AS incompatibility_pattern,
        left(query, 220) AS query_snippet
    FROM pg_stat_statements
    WHERE query ~* '\\blisten\\b|\\bunlisten\\b|\\bcreate\\s+temp\\b|\\btemporary\\s+table\\b|\\bset\\s+(session|role|search_path)\\b|\\bdeclare\\b.*\\bcursor\\b|\\bpg_advisory_lock\\b|\\bpg_try_advisory_lock\\b'
)
SELECT
    incompatibility_pattern,
    queryid,
    calls,
    round(total_exec_time::numeric, 2) AS total_exec_time_ms,
    round(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
    query_snippet,
    CASE
        WHEN incompatibility_pattern IN ('LISTEN_UNLISTEN', 'SESSION_STATE_MUTATION', 'ADVISORY_LOCK_USAGE') THEN 'HIGH_RISK_FOR_TX_POOLING'
        WHEN incompatibility_pattern IN ('TEMP_TABLE_USAGE', 'CURSOR_USAGE') THEN 'MEDIUM_RISK_FOR_TX_POOLING'
        ELSE 'REVIEW'
    END AS risk_label
FROM patterns
ORDER BY calls DESC, total_exec_time DESC
LIMIT 120;
\else
SELECT
    'pg_stat_statements extension is not installed. Pattern detection unavailable.'::text AS guidance;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  incompatibility_pattern | queryid | calls | total_exec_time_ms | mean_exec_time_ms | query_snippet | risk_label 
-- -------------------------+---------+-------+--------------------+-------------------+---------------+------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
