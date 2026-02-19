/*
Purpose: Rank all databases by total size.
Area: Database Size
Usage: Connect to any database in the instance.
*/
SELECT
    d.datname AS database_name,
    pg_database_size(d.datname) AS size_bytes,
    pg_size_pretty(pg_database_size(d.datname)) AS size_pretty
FROM pg_database d
ORDER BY size_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | size_bytes  | size_pretty 
-- -----------------------------------+-------------+-------------
--  pgbench_test                      | 32236762815 | 30 GB
--  script_validation_20260218_172749 |   468563647 | 447 MB
--  perf_test                         |   436410047 | 416 MB
--  postgres                          |    40007359 | 38 MB
--  hypopg_lab                        |    36173503 | 34 MB
--  appdb                             |     8058559 | 7870 kB
--  template1                         |     8033983 | 7846 kB
--  template0                         |     7791119 | 7609 kB
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END
