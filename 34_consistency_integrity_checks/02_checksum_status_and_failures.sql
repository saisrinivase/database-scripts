/*
PostgreSQL DBA Script: Checksum Status And Failures
Purpose: Show checksum posture and checksum-failure evidence when available.
Area: Consistency and Integrity Checks
Usage: If checksums are off, rely on stronger backup/restore verification and storage diagnostics.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
DROP TABLE IF EXISTS pg_temp.checksum_status_and_failures_result;
CREATE TEMP TABLE pg_temp.checksum_status_and_failures_result (
    database_name name,
    data_checksums text,
    datname name,
    checksum_failures bigint,
    stats_reset timestamptz,
    integrity_signal text,
    action_hint text
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'pg_catalog'
          AND table_name = 'pg_stat_database'
          AND column_name = 'checksum_failures'
    ) THEN
        EXECUTE $sql$
            INSERT INTO pg_temp.checksum_status_and_failures_result
            SELECT
                current_database(),
                coalesce(current_setting('data_checksums', true), '(unknown)'),
                d.datname,
                s.checksum_failures,
                s.stats_reset,
                CASE
                    WHEN coalesce(current_setting('data_checksums', true), 'off') IN ('on', '1') AND s.checksum_failures = 0 THEN 'CHECKSUMS_ENABLED_NO_FAILURES'
                    WHEN coalesce(current_setting('data_checksums', true), 'off') IN ('on', '1') AND s.checksum_failures > 0 THEN 'CHECKSUM_FAILURES_DETECTED'
                    ELSE 'CHECKSUMS_DISABLED_OR_UNKNOWN'
                END,
                CASE
                    WHEN s.checksum_failures > 0 THEN 'Escalate: run storage and integrity triage, validate replicas/backups immediately.'
                    WHEN coalesce(current_setting('data_checksums', true), 'off') NOT IN ('on', '1') THEN 'Plan checksum-enabled cluster for stronger corruption detection in future upgrades/migrations.'
                    ELSE 'No immediate checksum-driven action.'
                END
            FROM pg_database d
            JOIN pg_stat_database s ON s.datid = d.oid
            WHERE NOT d.datistemplate
            ORDER BY s.checksum_failures DESC, d.datname
        $sql$;
    ELSE
        INSERT INTO pg_temp.checksum_status_and_failures_result (
            database_name,
            data_checksums,
            integrity_signal,
            action_hint
        )
        VALUES (
            current_database(),
            coalesce(current_setting('data_checksums', true), '(unknown)'),
            'CHECKSUM_FAILURE_COLUMNS_UNAVAILABLE',
            'checksum_failures columns are not available in this PostgreSQL version.'
        );
    END IF;
END;
$$;

SELECT *
FROM pg_temp.checksum_status_and_failures_result;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  database_name | data_checksums |              datname              | checksum_failures | stats_reset |       integrity_signal        |             action_hint              
-- ---------------+----------------+-----------------------------------+-------------------+-------------+-------------------------------+--------------------------------------
--  pgbench_test  | on             | appdb                             |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
--  pgbench_test  | on             | hypopg_lab                        |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
--  pgbench_test  | on             | perf_test                         |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
--  pgbench_test  | on             | pgbench_test                      |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
--  pgbench_test  | on             | postgres                          |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
--  pgbench_test  | on             | script_validation_20260218_172749 |                 0 |             | CHECKSUMS_ENABLED_NO_FAILURES | No immediate checksum-driven action.
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
