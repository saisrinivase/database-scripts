/*
PostgreSQL DBA Script: Tx Pooling Incompatible Patterns Pg Stat Statements
Purpose: Identify query patterns that are problematic in transaction pooling modes.
Area: Pooler and Proxy Diagnostics
Usage: Requires pg_stat_statements for query-level output. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic.
*/
CREATE TEMP TABLE IF NOT EXISTS tx_pooling_incompatible_patterns_result (
    incompatibility_pattern text,
    queryid bigint,
    calls bigint,
    total_exec_time_ms numeric,
    mean_exec_time_ms numeric,
    query_snippet text,
    risk_label text
);

TRUNCATE tx_pooling_incompatible_patterns_result;

DO $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO tx_pooling_incompatible_patterns_result
            WITH patterns AS (
                SELECT
                    queryid,
                    calls,
                    total_exec_time,
                    mean_exec_time,
                    CASE
                        WHEN query ~* '\blisten\b|\bunlisten\b' THEN 'LISTEN_UNLISTEN'
                        WHEN query ~* '\bcreate\s+temp\b|\btemporary\s+table\b' THEN 'TEMP_TABLE_USAGE'
                        WHEN query ~* '\bset\s+(session|role|search_path)\b' THEN 'SESSION_STATE_MUTATION'
                        WHEN query ~* '\bdeclare\b.*\bcursor\b' THEN 'CURSOR_USAGE'
                        WHEN query ~* '\bpg_advisory_lock\b|\bpg_try_advisory_lock\b' THEN 'ADVISORY_LOCK_USAGE'
                        ELSE 'OTHER'
                    END AS incompatibility_pattern,
                    query AS query_snippet
                FROM pg_stat_statements
                WHERE query ~* '\blisten\b|\bunlisten\b|\bcreate\s+temp\b|\btemporary\s+table\b|\bset\s+(session|role|search_path)\b|\bdeclare\b.*\bcursor\b|\bpg_advisory_lock\b|\bpg_try_advisory_lock\b'
            )
            SELECT
                incompatibility_pattern,
                queryid,
                calls,
                round(total_exec_time::numeric, 2),
                round(mean_exec_time::numeric, 2),
                query_snippet,
                CASE
                    WHEN incompatibility_pattern IN ('LISTEN_UNLISTEN', 'SESSION_STATE_MUTATION', 'ADVISORY_LOCK_USAGE') THEN 'HIGH_RISK_FOR_TX_POOLING'
                    WHEN incompatibility_pattern IN ('TEMP_TABLE_USAGE', 'CURSOR_USAGE') THEN 'MEDIUM_RISK_FOR_TX_POOLING'
                    ELSE 'REVIEW'
                END
            FROM patterns
            ORDER BY calls DESC, total_exec_time DESC
            LIMIT 120
        $sql$;
    ELSE
        INSERT INTO tx_pooling_incompatible_patterns_result(query_snippet, risk_label)
        VALUES ('pg_stat_statements extension is not installed. Pattern detection unavailable.', 'NO_PGSS');
    END IF;
END $$;

SELECT *
FROM tx_pooling_incompatible_patterns_result;

-- SAMPLE_OUTPUT_BEGIN
-- incompatibility_pattern | queryid | calls | query_snippet | risk_label
-- ------------------------+---------+-------+---------------+------------
-- TEMP_TABLE_USAGE        | 12345   |    10 | CREATE TEMP...| MEDIUM_RISK_FOR_TX_POOLING
-- SAMPLE_OUTPUT_END
