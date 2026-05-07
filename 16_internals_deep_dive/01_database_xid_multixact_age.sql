/*
PostgreSQL DBA Script: Database XID Multixact Age
Purpose: Show XID and multixact age by database to assess wraparound risk.
Area: Internals Deep Dive
Usage: Monitor regularly on high-write systems.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    datname AS database_name,
    age(datfrozenxid) AS xid_age,
    mxid_age(datminmxid) AS multixact_age,
    datconnlimit,
    datallowconn
FROM pg_database
ORDER BY xid_age DESC, multixact_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | xid_age | multixact_age | datconnlimit | datallowconn 
-- -----------------------------------+---------+---------------+--------------+--------------
--  postgres                          | 5334012 |             0 |           -1 | t
--  perf_test                         | 5334012 |             0 |           -1 | t
--  template1                         | 5334012 |             0 |           -1 | t
--  template0                         | 5334012 |             0 |           -1 | f
--  appdb                             | 5334012 |             0 |           -1 | t
--  hypopg_lab                        | 5334012 |             0 |           -1 | t
--  pgbench_test                      | 5334012 |             0 |           -1 | t
--  script_validation_20260218_172749 | 5334012 |             0 |           -1 | t
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END

