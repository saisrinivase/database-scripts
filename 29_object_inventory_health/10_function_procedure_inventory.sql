/*
Purpose: Inventory functions/procedures with performance and safety attributes.
Area: Object Inventory and Health
Usage: Use to detect dynamic SQL, SECURITY DEFINER risk, and hot routines.
*/
WITH routine_base AS (
    SELECT
        p.oid AS proc_oid,
        n.nspname AS schema_name,
        p.proname AS routine_name,
        CASE p.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END AS routine_type,
        pg_get_function_identity_arguments(p.oid) AS identity_args,
        l.lanname AS language_name,
        CASE p.provolatile
            WHEN 'i' THEN 'IMMUTABLE'
            WHEN 's' THEN 'STABLE'
            WHEN 'v' THEN 'VOLATILE'
            ELSE p.provolatile::text
        END AS volatility,
        CASE WHEN p.prosecdef THEN 'SECURITY_DEFINER' ELSE 'SECURITY_INVOKER' END AS security_mode,
        CASE p.proparallel
            WHEN 's' THEN 'SAFE'
            WHEN 'r' THEN 'RESTRICTED'
            WHEN 'u' THEN 'UNSAFE'
            ELSE p.proparallel::text
        END AS parallel_safety,
        p.procost,
        p.prorows,
        pg_get_userbyid(p.proowner) AS owner_name,
        CASE
            WHEN l.lanname = 'plpgsql'
             AND position('EXECUTE ' IN upper(pg_get_functiondef(p.oid))) > 0
                THEN 'DYNAMIC_SQL_DETECTED'
            ELSE 'NO_DYNAMIC_SQL_MARKER'
        END AS dynamic_sql_flag
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    JOIN pg_language l ON l.oid = p.prolang
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND p.prokind IN ('f', 'p')
)
SELECT
    b.schema_name,
    b.routine_name,
    b.routine_type,
    b.identity_args,
    b.language_name,
    b.volatility,
    b.security_mode,
    b.parallel_safety,
    b.procost,
    b.prorows,
    b.owner_name,
    coalesce(s.calls, 0) AS calls,
    round(coalesce(s.total_time, 0)::numeric, 2) AS total_time_ms,
    round(coalesce(s.self_time, 0)::numeric, 2) AS self_time_ms,
    b.dynamic_sql_flag
FROM routine_base b
LEFT JOIN pg_stat_user_functions s
  ON s.funcid = b.proc_oid
ORDER BY
    coalesce(s.total_time, 0) DESC,
    b.schema_name,
    b.routine_name,
    b.routine_type;
