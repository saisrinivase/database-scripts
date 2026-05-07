/*
PostgreSQL DBA Script: Parameter Pending Restart Drift
Purpose: Detect pending-restart parameters and configuration drift from defaults.
Area: Cloud Provider Signals
Usage: Useful after parameter-group or flag changes in managed services.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    name,
    setting,
    unit,
    source,
    sourcefile,
    sourceline,
    pending_restart,
    boot_val,
    reset_val,
    CASE
        WHEN pending_restart THEN 'PENDING_RESTART'
        WHEN source <> 'default' THEN 'NON_DEFAULT_SETTING'
        ELSE 'DEFAULT'
    END AS drift_label
FROM pg_settings
WHERE pending_restart
   OR source <> 'default'
ORDER BY pending_restart DESC, name
LIMIT 400;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--                name                |                     setting                     | unit |       source       |                      sourcefile                      | sourceline | pending_restart |     boot_val      |                    reset_val                    |     drift_label     
-- -----------------------------------+-------------------------------------------------+------+--------------------+------------------------------------------------------+------------+-----------------+-------------------+-------------------------------------------------+---------------------
--  application_name                  | psql                                            |      | client             |                                                      |            | f               |                   | psql                                            | NON_DEFAULT_SETTING
--  autovacuum_worker_slots           | 16                                              |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        683 | f               | 16                | 16                                              | NON_DEFAULT_SETTING
--  config_file                       | /opt/homebrew/var/postgresql@18/postgresql.conf |      | override           |                                                      |            | f               |                   | /opt/homebrew/var/postgresql@18/postgresql.conf | NON_DEFAULT_SETTING
--  data_directory                    | /opt/homebrew/var/postgresql@18                 |      | override           |                                                      |            | f               |                   | /opt/homebrew/var/postgresql@18                 | NON_DEFAULT_SETTING
--  DateStyle                         | ISO, MDY                                        |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        777 | f               | ISO, MDY          | ISO, MDY                                        | NON_DEFAULT_SETTING
--  default_text_search_config        | pg_catalog.english                              |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        803 | f               | pg_catalog.simple | pg_catalog.english                              | NON_DEFAULT_SETTING
--  dynamic_shared_memory_type        | posix                                           |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        155 | f               | posix             | posix                                           | NON_DEFAULT_SETTING
--  full_page_writes                  | off                                             |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.auto.conf |          3 | f               | on                | off                                             | NON_DEFAULT_SETTING
--  hba_file                          | /opt/homebrew/var/postgresql@18/pg_hba.conf     |      | override           |                                                      |            | f               |                   | /opt/homebrew/var/postgresql@18/pg_hba.conf     | NON_DEFAULT_SETTING
--  ident_file                        | /opt/homebrew/var/postgresql@18/pg_ident.conf   |      | override           |                                                      |            | f               |                   | /opt/homebrew/var/postgresql@18/pg_ident.conf   | NON_DEFAULT_SETTING
--  lc_messages                       | en_US.UTF-8                                     |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        793 | f               |                   | en_US.UTF-8                                     | NON_DEFAULT_SETTING
--  lc_monetary                       | en_US.UTF-8                                     |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        795 | f               | C                 | en_US.UTF-8                                     | NON_DEFAULT_SETTING
--  lc_numeric                        | en_US.UTF-8                                     |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        796 | f               | C                 | en_US.UTF-8                                     | NON_DEFAULT_SETTING
--  lc_time                           | en_US.UTF-8                                     |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        797 | f               | C                 | en_US.UTF-8                                     | NON_DEFAULT_SETTING
--  log_timezone                      | America/New_York                                |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        641 | f               | GMT               | America/New_York                                | NON_DEFAULT_SETTING
--  max_connections                   | 100                                             |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |         65 | f               | 100               | 100                                             | NON_DEFAULT_SETTING
--  max_wal_size                      | 1024                                            | MB   | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        267 | f               | 1024              | 1024                                            | NON_DEFAULT_SETTING
--  min_wal_size                      | 80                                              | MB   | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        268 | f               | 80                | 80                                              | NON_DEFAULT_SETTING
--  pg_stat_statements.max            | 10000                                           |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        892 | f               | 5000              | 10000                                           | NON_DEFAULT_SETTING
--  pg_stat_statements.track          | all                                             |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        891 | f               | top               | all                                             | NON_DEFAULT_SETTING
--  pg_stat_statements.track_planning | on                                              |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        893 | f               | off               | on                                              | NON_DEFAULT_SETTING
--  shared_buffers                    | 16384                                           | 8kB  | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        132 | f               | 16384             | 16384                                           | NON_DEFAULT_SETTING
--  shared_preload_libraries          | pg_stat_statements                              |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        889 | f               |                   | pg_stat_statements                              | NON_DEFAULT_SETTING
--  TimeZone                          | America/New_York                                |      | configuration file | /opt/homebrew/var/postgresql@18/postgresql.conf      |        779 | f               | GMT               | America/New_York                                | NON_DEFAULT_SETTING
--  transaction_deferrable            | off                                             |      | override           |                                                      |            | f               | off               | off                                             | NON_DEFAULT_SETTING
--  transaction_isolation             | read committed                                  |      | override           |                                                      |            | f               | read committed    | read committed                                  | NON_DEFAULT_SETTING
--  transaction_read_only             | off                                             |      | override           |                                                      |            | f               | off               | off                                             | NON_DEFAULT_SETTING
-- (27 rows)
-- 
-- SAMPLE_OUTPUT_END
