/*
Purpose: Audit VOLATILE and SECURITY DEFINER functions for performance and security review.
Area: Functions and Dynamic SQL
Usage: VOLATILE can affect planner choices; SECURITY DEFINER needs strict controls.
*/
SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS function_args,
    p.provolatile,
    p.prosecdef AS security_definer,
    l.lanname AS language_name
FROM pg_proc p
JOIN pg_namespace n
    ON n.oid = p.pronamespace
JOIN pg_language l
    ON l.oid = p.prolang
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND (p.provolatile = 'v' OR p.prosecdef)
ORDER BY schema_name, function_name;
