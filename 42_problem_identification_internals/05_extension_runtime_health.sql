/*
PostgreSQL DBA Script: Extension Runtime Health
Purpose: Detect installation and runtime signals for pg_cron, TimescaleDB, Citus, and pgvector without failing when extensions are absent.
Area: Problem Identification and Internals
Usage: Run in each application database; extension metadata and permissions can differ by database and managed service.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Creates only a session-local temporary table. Extension-specific catalogs are queried only after capability checks.
*/
CREATE TEMP TABLE IF NOT EXISTS extension_runtime_health_result (
    extension_name text,
    signal_name text,
    signal_value numeric,
    health_status text,
    diagnosis text
);

TRUNCATE extension_runtime_health_result;

INSERT INTO extension_runtime_health_result
SELECT
    x.extension_name,
    'installed',
    CASE WHEN e.extname IS NULL THEN 0 ELSE 1 END,
    CASE WHEN e.extname IS NULL THEN 'NOT_INSTALLED' ELSE 'INSTALLED_' || e.extversion END,
    x.purpose
FROM (VALUES
    ('pg_cron', 'In-database SQL job scheduler; check jobs and failed runs.'),
    ('timescaledb', 'Time-series hypertables, policies, compression, and continuous aggregates.'),
    ('citus', 'Distributed tables, shards, and worker-node health.'),
    ('vector', 'pgvector data type and HNSW/IVFFlat index capability.')
) AS x(extension_name, purpose)
LEFT JOIN pg_extension e ON e.extname = x.extension_name;

DO $$
BEGIN
    IF to_regclass('cron.job') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO extension_runtime_health_result
            SELECT
                'pg_cron',
                'inactive_jobs',
                count(*) FILTER (WHERE NOT active),
                CASE WHEN count(*) FILTER (WHERE NOT active) > 0 THEN 'REVIEW' ELSE 'OK' END,
                'Inactive jobs may be intentional; compare with the approved schedule inventory.'
            FROM cron.job
        $sql$;
    END IF;

    IF to_regclass('cron.job_run_details') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO extension_runtime_health_result
            SELECT
                'pg_cron',
                'failed_runs_24h',
                count(*) FILTER (
                    WHERE to_jsonb(r)->>'status' = 'failed'
                      AND NULLIF(to_jsonb(r)->>'end_time', '')::timestamptz >= clock_timestamp() - interval '24 hours'
                ),
                CASE WHEN count(*) FILTER (
                    WHERE to_jsonb(r)->>'status' = 'failed'
                      AND NULLIF(to_jsonb(r)->>'end_time', '')::timestamptz >= clock_timestamp() - interval '24 hours'
                ) > 0 THEN 'HIGH' ELSE 'OK' END,
                'Inspect return_message and the SQL command for recent failed jobs.'
            FROM cron.job_run_details r
        $sql$;
    END IF;

    IF to_regclass('timescaledb_information.hypertables') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO extension_runtime_health_result
            SELECT
                'timescaledb',
                'hypertable_count',
                count(*),
                CASE WHEN count(*) > 0 THEN 'OK' ELSE 'REVIEW' END,
                'Confirm chunk interval, retention, compression, and policy jobs for every hypertable.'
            FROM timescaledb_information.hypertables
        $sql$;
    END IF;

    IF to_regclass('pg_catalog.pg_dist_node') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO extension_runtime_health_result
            SELECT
                'citus',
                'inactive_primary_nodes',
                count(*) FILTER (
                    WHERE coalesce((to_jsonb(n)->>'isactive')::boolean, false) = false
                      AND coalesce(to_jsonb(n)->>'noderole', 'primary') = 'primary'
                ),
                CASE WHEN count(*) FILTER (
                    WHERE coalesce((to_jsonb(n)->>'isactive')::boolean, false) = false
                      AND coalesce(to_jsonb(n)->>'noderole', 'primary') = 'primary'
                ) > 0 THEN 'HIGH' ELSE 'OK' END,
                'Inactive primary worker nodes can make shards unavailable.'
            FROM pg_catalog.pg_dist_node n
        $sql$;
    END IF;
END $$;

INSERT INTO extension_runtime_health_result
SELECT
    'vector',
    'ann_index_count',
    count(*),
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector') AND count(*) = 0 THEN 'REVIEW'
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector') THEN 'OK'
        ELSE 'NOT_APPLICABLE'
    END,
    'HNSW and IVFFlat indexes accelerate approximate nearest-neighbor search; validate recall and filtering with workload tests.'
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
JOIN pg_am a ON a.oid = c.relam
WHERE a.amname IN ('hnsw', 'ivfflat');

SELECT
    extension_name,
    signal_name,
    signal_value,
    health_status,
    diagnosis
FROM extension_runtime_health_result
ORDER BY
    CASE health_status WHEN 'HIGH' THEN 1 WHEN 'REVIEW' THEN 2 WHEN 'NOT_INSTALLED' THEN 4 ELSE 3 END,
    extension_name,
    signal_name;

-- SAMPLE_OUTPUT_BEGIN
-- extension_name | signal_name | signal_value | health_status | diagnosis
-- pg_cron       | installed   | 1            | INSTALLED_1.6 | In-database SQL job scheduler...
-- vector        | ann_index_count | 0        | REVIEW        | HNSW and IVFFlat indexes...
-- SAMPLE_OUTPUT_END
