/*
Purpose: Audit privilege exposure, with focus on PUBLIC grants and grant-option chains.
Area: Object Inventory and Health
Usage: Review regularly for least-privilege posture and migration cutover hardening.
*/
WITH table_grants AS (
    SELECT
        'TABLE'::text AS object_type,
        tp.table_schema AS object_schema,
        tp.table_name AS object_name,
        tp.grantee,
        tp.privilege_type,
        tp.is_grantable,
        CASE
            WHEN tp.grantee = 'PUBLIC' THEN 'HIGH'
            WHEN tp.is_grantable = 'YES' AND tp.grantee <> pg_get_userbyid(c.relowner) THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM information_schema.table_privileges tp
    JOIN pg_namespace n
      ON n.nspname = tp.table_schema
    JOIN pg_class c
      ON c.relnamespace = n.oid
     AND c.relname = tp.table_name
     AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
    WHERE tp.table_schema !~ '^pg_'
      AND tp.table_schema <> 'information_schema'
),
routine_owner AS (
    SELECT
        n.nspname AS routine_schema,
        p.proname AS routine_name,
        array_agg(DISTINCT pg_get_userbyid(p.proowner)) AS owner_names
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY n.nspname, p.proname
),
routine_grants AS (
    SELECT
        'ROUTINE'::text AS object_type,
        rp.routine_schema AS object_schema,
        rp.routine_name AS object_name,
        rp.grantee,
        rp.privilege_type,
        rp.is_grantable,
        CASE
            WHEN rp.grantee = 'PUBLIC' THEN 'HIGH'
            WHEN rp.is_grantable = 'YES'
             AND NOT (rp.grantee = ANY(coalesce(ro.owner_names, ARRAY[]::text[]))) THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM information_schema.routine_privileges rp
    LEFT JOIN routine_owner ro
      ON ro.routine_schema = rp.routine_schema
     AND ro.routine_name = rp.routine_name
    WHERE rp.routine_schema !~ '^pg_'
      AND rp.routine_schema <> 'information_schema'
)
SELECT
    object_type,
    object_schema,
    object_name,
    grantee,
    privilege_type,
    is_grantable,
    risk_level,
    CASE
        WHEN grantee = 'PUBLIC' THEN 'Consider REVOKE from PUBLIC and grant via roles.'
        WHEN is_grantable = 'YES' THEN 'Validate delegation model and remove grant option if not required.'
        ELSE 'No immediate issue.'
    END AS recommendation
FROM (
    SELECT * FROM table_grants
    UNION ALL
    SELECT * FROM routine_grants
) x
WHERE risk_level <> 'LOW'
ORDER BY
    CASE risk_level WHEN 'HIGH' THEN 0 WHEN 'MEDIUM' THEN 1 ELSE 2 END,
    object_schema,
    object_name,
    grantee,
    privilege_type;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 object_type |  object_schema   |        object_name        | grantee | privilege_type | is_grantable | risk_level |                  recommendation                  
-------------+------------------+---------------------------+---------+----------------+--------------+------------+--------------------------------------------------
 ROUTINE     | migration_v2_lab | fn_calc_fee               | PUBLIC  | EXECUTE        | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 ROUTINE     | migration_v2_lab | fn_set_updated_at         | PUBLIC  | EXECUTE        | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 ROUTINE     | migration_v2_lab | prc_tag_high_value_orders | PUBLIC  | EXECUTE        | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 ROUTINE     | public           | pg_stat_statements        | PUBLIC  | EXECUTE        | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 TABLE       | public           | pg_stat_statements        | PUBLIC  | SELECT         | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 ROUTINE     | public           | pg_stat_statements_info   | PUBLIC  | EXECUTE        | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
 TABLE       | public           | pg_stat_statements_info   | PUBLIC  | SELECT         | NO           | HIGH       | Consider REVOKE from PUBLIC and grant via roles.
(7 rows)


SAMPLE_OUTPUT_END */
