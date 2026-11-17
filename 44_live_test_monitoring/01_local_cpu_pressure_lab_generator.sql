/*
PostgreSQL DBA Script: Bounded Local CPU Pressure Lab Generator
Purpose: Create a recognizable, time-bounded PostgreSQL CPU workload for validating live diagnostics.
Area: Live Test Monitoring
Compatibility: PostgreSQL 15+.
Usage: LOCAL OR DISPOSABLE TEST DATABASES ONLY. Run in pgAdmin tab 1, then run
       02_identify_active_cpu_processes_pgadmin.sql repeatedly from tab 2 while this query is active.
       Optional duration (1-120 seconds):
       SELECT set_config('pgdiag.cpu_pressure_seconds', '30', false);
Sample Output: See SAMPLE_OUTPUT_BEGIN below.
Notes: Never run this workload generator on production, RDS, Aurora, or another shared database.
       It creates a transaction-local pg_temp function and sets a recognizable application_name.
       ROLLBACK removes the function and restores session settings. statement_timeout provides a second safety boundary.
*/

BEGIN;

SELECT set_config('application_name', 'pgdiag_cpu_pressure_lab', true);
SELECT set_config('statement_timeout', '130s', true);

CREATE OR REPLACE FUNCTION pg_temp.generate_cpu_pressure(p_duration_seconds integer)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
SET search_path = pg_catalog, pg_temp
AS $$
DECLARE
    v_deadline timestamptz;
    v_iterations bigint := 0;
    v_hash text := 'pgdiag';
BEGIN
    IF p_duration_seconds < 1 OR p_duration_seconds > 120 THEN
        RAISE EXCEPTION 'CPU pressure duration must be between 1 and 120 seconds';
    END IF;

    v_deadline := clock_timestamp() + make_interval(secs => p_duration_seconds);
    WHILE clock_timestamp() < v_deadline LOOP
        v_hash := md5(v_hash || v_iterations::text);
        v_iterations := v_iterations + 1;
    END LOOP;

    RETURN v_iterations + length(v_hash) - length(v_hash);
END;
$$;

SELECT
    pg_backend_pid() AS backend_pid,
    current_database() AS database_name,
    current_setting('application_name') AS application_name,
    pg_temp.generate_cpu_pressure(
        coalesce(nullif(current_setting('pgdiag.cpu_pressure_seconds', true), '')::integer, 30)
    ) AS completed_iterations;

ROLLBACK;

-- SAMPLE_OUTPUT_BEGIN
-- backend_pid | database_name | application_name           | completed_iterations
-- 93836       | postgres      | pgdiag_cpu_pressure_lab    | 52376438
-- SAMPLE_OUTPUT_END
