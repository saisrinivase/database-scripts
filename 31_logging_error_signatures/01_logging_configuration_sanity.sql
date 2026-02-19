/*
Purpose: Validate key logging parameters for performance troubleshooting and incident diagnostics.
Area: Logging and Error Signatures
Usage: Review parameters marked GAP or WARN and align with environment standards.
*/
WITH expected(name, recommendation, rationale) AS (
    VALUES
        ('log_line_prefix', 'include timestamp/pid/user/db/app/client', 'Supports fast root-cause correlation across sessions.'),
        ('log_lock_waits', 'on', 'Captures lock wait diagnostics in logs.'),
        ('deadlock_timeout', '100ms-1s', 'Lower values capture lock contention earlier.'),
        ('log_min_duration_statement', '>=0 in tuning windows, not -1', 'Required to capture slow SQL in logs.'),
        ('log_temp_files', '0 or small threshold', 'Detects temp spill storms and work_mem issues.'),
        ('log_checkpoints', 'on', 'Correlates checkpoint bursts with latency.'),
        ('log_autovacuum_min_duration', '0 to low threshold in investigations', 'Explains autovacuum impact during incidents.')
),
settings AS (
    SELECT
        e.name,
        e.recommendation,
        e.rationale,
        s.setting,
        s.unit,
        s.source
    FROM expected e
    LEFT JOIN pg_settings s
      ON s.name = e.name
)
SELECT
    name AS parameter_name,
    coalesce(setting, '(not available)') AS current_value,
    coalesce(unit, '') AS unit,
    recommendation,
    coalesce(source, '(n/a)') AS source,
    CASE
        WHEN name = 'log_line_prefix' AND setting ILIKE '%m%' AND setting ILIKE '%p%' AND setting ILIKE '%u%' AND setting ILIKE '%d%' THEN 'OK'
        WHEN name = 'log_lock_waits' AND setting = 'on' THEN 'OK'
        WHEN name = 'deadlock_timeout' AND setting ~ '^[0-9]+$' AND setting::int BETWEEN 100 AND 1000 THEN 'OK'
        WHEN name = 'log_min_duration_statement' AND setting <> '-1' THEN 'OK'
        WHEN name = 'log_temp_files' AND setting <> '-1' THEN 'OK'
        WHEN name = 'log_checkpoints' AND setting = 'on' THEN 'OK'
        WHEN name = 'log_autovacuum_min_duration' AND setting <> '-1' THEN 'OK'
        WHEN setting IS NULL THEN 'INFO'
        ELSE 'GAP'
    END AS status,
    rationale,
    CASE
        WHEN name = 'log_min_duration_statement' AND setting = '-1' THEN 'Set threshold (for example 500ms) during tuning windows.'
        WHEN name = 'log_temp_files' AND setting = '-1' THEN 'Enable temp file logging to catch sort/hash spills.'
        WHEN name = 'log_line_prefix' THEN 'Example: %m [%p] %u@%d app=%a client=%h '
        ELSE 'Adjust per workload and SRE logging policy.'
    END AS remediation
FROM settings
ORDER BY
    CASE
        WHEN name = 'log_line_prefix' THEN 1
        WHEN name = 'log_lock_waits' THEN 2
        WHEN name = 'deadlock_timeout' THEN 3
        WHEN name = 'log_min_duration_statement' THEN 4
        WHEN name = 'log_temp_files' THEN 5
        WHEN name = 'log_checkpoints' THEN 6
        ELSE 7
    END;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--        parameter_name        | current_value | unit |              recommendation              | source  | status |                       rationale                       |                       remediation                        
-- -----------------------------+---------------+------+------------------------------------------+---------+--------+-------------------------------------------------------+----------------------------------------------------------
--  log_line_prefix             | %m [%p]       |      | include timestamp/pid/user/db/app/client | default | GAP    | Supports fast root-cause correlation across sessions. | Example: %m [%p] %u@%d app=%a client=%h 
--  log_lock_waits              | off           |      | on                                       | default | GAP    | Captures lock wait diagnostics in logs.               | Adjust per workload and SRE logging policy.
--  deadlock_timeout            | 1000          | ms   | 100ms-1s                                 | default | OK     | Lower values capture lock contention earlier.         | Adjust per workload and SRE logging policy.
--  log_min_duration_statement  | -1            | ms   | >=0 in tuning windows, not -1            | default | GAP    | Required to capture slow SQL in logs.                 | Set threshold (for example 500ms) during tuning windows.
--  log_temp_files              | -1            | kB   | 0 or small threshold                     | default | GAP    | Detects temp spill storms and work_mem issues.        | Enable temp file logging to catch sort/hash spills.
--  log_checkpoints             | on            |      | on                                       | default | OK     | Correlates checkpoint bursts with latency.            | Adjust per workload and SRE logging policy.
--  log_autovacuum_min_duration | 600000        | ms   | 0 to low threshold in investigations     | default | OK     | Explains autovacuum impact during incidents.          | Adjust per workload and SRE logging policy.
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END

