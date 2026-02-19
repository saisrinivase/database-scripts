/*
Purpose: Surface recurring error-like signatures from PostgreSQL statistics (deadlocks, conflicts, rollback spikes, temp storms).
Area: Logging and Error Signatures
Usage: Run during or after incidents to prioritize likely failure modes.
*/
WITH db AS (
    SELECT
        d.datname,
        s.numbackends,
        s.xact_commit,
        s.xact_rollback,
        s.deadlocks,
        s.temp_files,
        s.temp_bytes,
        s.blk_read_time,
        s.blk_write_time,
        s.checksum_failures,
        c.confl_tablespace + c.confl_lock + c.confl_snapshot + c.confl_bufferpin + c.confl_deadlock AS total_conflicts
    FROM pg_database d
    JOIN pg_stat_database s
      ON s.datid = d.oid
    LEFT JOIN pg_stat_database_conflicts c
      ON c.datid = d.oid
    WHERE NOT d.datistemplate
)
SELECT
    datname AS database_name,
    numbackends,
    xact_commit,
    xact_rollback,
    round(
        CASE WHEN xact_commit + xact_rollback = 0 THEN 0
             ELSE 100.0 * xact_rollback::numeric / (xact_commit + xact_rollback)
        END,
        2
    ) AS rollback_pct,
    deadlocks,
    total_conflicts,
    temp_files,
    pg_size_pretty(temp_bytes) AS temp_bytes_pretty,
    round((coalesce(blk_read_time, 0) + coalesce(blk_write_time, 0))::numeric, 2) AS io_time_ms,
    checksum_failures,
    CASE
        WHEN deadlocks > 0 THEN 'DEADLOCK_SIGNATURE'
        WHEN total_conflicts > 0 THEN 'RECOVERY_CONFLICT_SIGNATURE'
        WHEN xact_commit + xact_rollback > 0
             AND xact_rollback::numeric / (xact_commit + xact_rollback) > 0.05 THEN 'HIGH_ROLLBACK_SIGNATURE'
        WHEN temp_bytes > 2::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_STORM_SIGNATURE'
        WHEN checksum_failures > 0 THEN 'CHECKSUM_FAILURE_SIGNATURE'
        ELSE 'NO_STRONG_SIGNATURE'
    END AS primary_signature,
    CASE
        WHEN deadlocks > 0 THEN 'Inspect lock order and long-running transactions.'
        WHEN total_conflicts > 0 THEN 'Inspect standby conflict types and query cancellation behavior.'
        WHEN xact_commit + xact_rollback > 0
             AND xact_rollback::numeric / (xact_commit + xact_rollback) > 0.05 THEN 'Inspect serialization/constraint retry patterns in application logs.'
        WHEN temp_bytes > 2::bigint * 1024 * 1024 * 1024 THEN 'Review work_mem, hash/sort plans, and temp file heavy statements.'
        WHEN checksum_failures > 0 THEN 'Escalate integrity check and storage diagnostics immediately.'
        ELSE 'Continue with query-level and lock-level analysis.'
    END AS next_action
FROM db
ORDER BY
    CASE
        WHEN deadlocks > 0 THEN 1
        WHEN total_conflicts > 0 THEN 2
        WHEN checksum_failures > 0 THEN 3
        ELSE 4
    END,
    temp_bytes DESC,
    rollback_pct DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--            database_name           | numbackends | xact_commit | xact_rollback | rollback_pct | deadlocks | total_conflicts | temp_files | temp_bytes_pretty | io_time_ms | checksum_failures |     primary_signature      |                            next_action                            
-- -----------------------------------+-------------+-------------+---------------+--------------+-----------+-----------------+------------+-------------------+------------+-------------------+----------------------------+-------------------------------------------------------------------
--  pgbench_test                      |           1 |     8160813 |           346 |         0.00 |         0 |               0 |        111 | 4164 MB           |       0.00 |                 0 | TEMP_SPILL_STORM_SIGNATURE | Review work_mem, hash/sort plans, and temp file heavy statements.
--  script_validation_20260218_172749 |           0 |        3444 |            24 |         0.69 |         0 |               0 |          4 | 6563 kB           |       0.00 |                 0 | NO_STRONG_SIGNATURE        | Continue with query-level and lock-level analysis.
--  postgres                          |           0 |       11369 |            12 |         0.11 |         0 |               0 |          3 | 4922 kB           |       0.00 |                 0 | NO_STRONG_SIGNATURE        | Continue with query-level and lock-level analysis.
--  appdb                             |           0 |       10159 |            16 |         0.16 |         0 |               0 |          0 | 0 bytes           |       0.00 |                 0 | NO_STRONG_SIGNATURE        | Continue with query-level and lock-level analysis.
--  perf_test                         |           0 |        9405 |             2 |         0.02 |         0 |               0 |          0 | 0 bytes           |       0.00 |                 0 | NO_STRONG_SIGNATURE        | Continue with query-level and lock-level analysis.
--  hypopg_lab                        |           0 |        9399 |             0 |         0.00 |         0 |               0 |          0 | 0 bytes           |       0.00 |                 0 | NO_STRONG_SIGNATURE        | Continue with query-level and lock-level analysis.
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
