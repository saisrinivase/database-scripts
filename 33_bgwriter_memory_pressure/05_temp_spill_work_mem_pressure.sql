/*
PostgreSQL DBA Script: Temp Spill Work Mem Pressure
Purpose: Identify memory-pressure symptoms from temp spill volume and work_mem-sensitive query behavior.
Area: Background Processes and Memory Pressure
Usage: Use alongside EXPLAIN to tune work_mem and query plans safely. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Query-level output is available when pg_stat_statements is installed.
*/
WITH cfg AS (
    SELECT
        current_setting('work_mem') AS work_mem,
        current_setting('maintenance_work_mem') AS maintenance_work_mem,
        current_setting('temp_file_limit', true) AS temp_file_limit
),
db AS (
    SELECT
        datname,
        temp_files,
        temp_bytes,
        xact_commit + xact_rollback AS total_xacts,
        stats_reset
    FROM pg_stat_database
    WHERE datname = current_database()
)
SELECT
    'step_01_database_temp_pressure' AS section,
    d.datname AS database_name,
    c.work_mem,
    c.maintenance_work_mem,
    coalesce(c.temp_file_limit, '(not set)') AS temp_file_limit,
    d.temp_files,
    pg_size_pretty(d.temp_bytes) AS temp_bytes_pretty,
    round(CASE WHEN d.total_xacts = 0 THEN 0 ELSE d.temp_bytes::numeric / d.total_xacts END, 2) AS temp_bytes_per_xact,
    d.stats_reset,
    CASE
        WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'SEVERE_SPILL_PRESSURE'
        WHEN d.temp_bytes > 1::bigint * 1024 * 1024 * 1024 THEN 'MODERATE_SPILL_PRESSURE'
        ELSE 'LOW_SPILL_PRESSURE'
    END AS pressure_label
FROM cfg c
CROSS JOIN db d;

CREATE TEMP TABLE IF NOT EXISTS temp_spill_query_pressure_result (
    section text,
    queryid bigint,
    calls bigint,
    total_exec_time_ms numeric,
    mean_exec_time_ms numeric,
    temp_blks_written bigint,
    temp_written_pretty text,
    shared_blks_read bigint,
    query_snippet text
);

TRUNCATE temp_spill_query_pressure_result;

DO $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO temp_spill_query_pressure_result
            SELECT
                'step_02_query_temp_spill_pressure',
                queryid,
                calls,
                round(total_exec_time::numeric, 2),
                round(mean_exec_time::numeric, 2),
                temp_blks_written,
                pg_size_pretty(temp_blks_written::bigint * current_setting('block_size')::int),
                shared_blks_read,
                left(query, 220)
            FROM pg_stat_statements
            WHERE temp_blks_written > 0
            ORDER BY temp_blks_written DESC, total_exec_time DESC
            LIMIT 60
        $sql$;
    ELSE
        INSERT INTO temp_spill_query_pressure_result(section, query_snippet)
        VALUES ('step_02_query_temp_spill_pressure', 'pg_stat_statements extension is not installed. Query-level spill attribution unavailable.');
    END IF;
END $$;

SELECT *
FROM temp_spill_query_pressure_result;

-- SAMPLE_OUTPUT_BEGIN
-- section                         | queryid | calls | temp_blks_written | temp_written_pretty | query_snippet
-- --------------------------------+---------+-------+-------------------+---------------------+--------------
-- step_02_query_temp_spill_pressure | 12345 |    10 |              1000 | 8000 kB             | SELECT ...
-- SAMPLE_OUTPUT_END
