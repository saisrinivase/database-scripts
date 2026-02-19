/*
Purpose: Detect ETL/KETTLE-like activity patterns from active sessions and role naming.
Area: Object Inventory and Health
Usage: Correlate ETL windows with locking, I/O pressure, and long-running statements.
*/
WITH etl_sessions AS (
    SELECT
        pid,
        usename,
        datname,
        coalesce(application_name, '') AS application_name,
        client_addr,
        state,
        wait_event_type,
        wait_event,
        now() - query_start AS query_age,
        left(query, 240) AS query_snippet
    FROM pg_stat_activity
    WHERE backend_type = 'client backend'
      AND (
            application_name ~* '(kettle|pentaho|spoon|pan|kitchen|etl|batch)'
         OR usename ~* '(etl|batch|kettle|pentaho)'
      )
),
etl_roles AS (
    SELECT
        rolname,
        rolsuper,
        rolcreaterole,
        rolcreatedb,
        rolreplication
    FROM pg_roles
    WHERE rolname ~* '(etl|batch|kettle|pentaho)'
)
SELECT
    'SESSION'::text AS signal_type,
    pid::text AS signal_id,
    usename AS principal,
    datname AS database_name,
    application_name,
    state,
    coalesce(wait_event_type, '') AS wait_event_type,
    coalesce(wait_event, '') AS wait_event,
    query_age::text AS duration,
    query_snippet AS details
FROM etl_sessions
UNION ALL
SELECT
    'ROLE'::text,
    rolname,
    rolname,
    '',
    '',
    CASE WHEN rolsuper THEN 'SUPERUSER' ELSE 'NON_SUPERUSER' END,
    '',
    '',
    '',
    format('create_role=%s create_db=%s replication=%s', rolcreaterole, rolcreatedb, rolreplication)
FROM etl_roles
ORDER BY signal_type, signal_id;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  signal_type | signal_id | principal | database_name | application_name | state | wait_event_type | wait_event | duration | details 
-- -------------+-----------+-----------+---------------+------------------+-------+-----------------+------------+----------+---------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No KETTLE/ETL-like sessions or roles matched at capture time.
-- - This is expected outside ETL windows or when application_name/role naming differs.
-- SAMPLE_OUTPUT_END
