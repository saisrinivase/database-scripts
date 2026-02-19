/*
Purpose: List prepared transactions (2PC) and their age.
Area: Connection and Workload
Usage: Stale prepared transactions can block cleanup and hold locks.
*/
SELECT
    transaction,
    gid,
    prepared,
    owner,
    database,
    now() - prepared AS prepared_age
FROM pg_prepared_xacts
ORDER BY prepared_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  transaction | gid | prepared | owner | database | prepared_age 
-- -------------+-----+----------+-------+----------+--------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No rows matched in this environment at capture time.
-- - This can be expected when the related object/feature is not present or not in use.
-- SAMPLE_OUTPUT_END
