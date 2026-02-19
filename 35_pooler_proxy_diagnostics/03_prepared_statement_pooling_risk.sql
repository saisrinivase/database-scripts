/*
Purpose: Detect prepared-statement patterns that can break or degrade transaction pooling modes.
Area: Pooler and Proxy Diagnostics
Usage: Review when using PgBouncer transaction pooling or proxies with statement lifecycle constraints.
*/
WITH summary AS (
    SELECT
        count(*) AS prepared_statement_count,
        count(*) FILTER (WHERE from_sql) AS sql_prepared_count,
        count(*) FILTER (WHERE NOT from_sql) AS protocol_prepared_count,
        min(prepare_time) AS oldest_prepare_time,
        max(prepare_time) AS newest_prepare_time,
        sum(generic_plans) AS total_generic_plans,
        sum(custom_plans) AS total_custom_plans
    FROM pg_prepared_statements
),
cfg AS (
    SELECT
        current_setting('max_prepared_transactions')::int AS max_prepared_transactions
)
SELECT
    c.max_prepared_transactions,
    s.prepared_statement_count,
    s.sql_prepared_count,
    s.protocol_prepared_count,
    s.oldest_prepare_time,
    s.newest_prepare_time,
    s.total_generic_plans,
    s.total_custom_plans,
    CASE
        WHEN s.prepared_statement_count = 0 THEN 'NO_PREPARED_STATEMENTS_VISIBLE'
        WHEN s.prepared_statement_count > 500 THEN 'HIGH_PREPARED_STATEMENT_FOOTPRINT'
        WHEN s.protocol_prepared_count > s.sql_prepared_count THEN 'PROTOCOL_PREPARED_DOMINANT'
        ELSE 'MODERATE_PREPARED_USAGE'
    END AS pooling_risk_label,
    CASE
        WHEN s.prepared_statement_count > 0 THEN 'Validate pooler mode and prepared-statement reset policy.'
        ELSE 'No immediate prepared-statement pooling conflict signal.'
    END AS action_hint
FROM cfg c
CROSS JOIN summary s;

SELECT
    name,
    from_sql,
    prepare_time,
    generic_plans,
    custom_plans,
    left(statement, 220) AS statement_snippet
FROM pg_prepared_statements
ORDER BY prepare_time ASC
LIMIT 120;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  max_prepared_transactions | prepared_statement_count | sql_prepared_count | protocol_prepared_count | oldest_prepare_time | newest_prepare_time | total_generic_plans | total_custom_plans |       pooling_risk_label       |                       action_hint                        
-- ---------------------------+--------------------------+--------------------+-------------------------+---------------------+---------------------+---------------------+--------------------+--------------------------------+----------------------------------------------------------
--                          0 |                        0 |                  0 |                       0 |                     |                     |                     |                    | NO_PREPARED_STATEMENTS_VISIBLE | No immediate prepared-statement pooling conflict signal.
-- (1 row)
-- 
--  name | from_sql | prepare_time | generic_plans | custom_plans | statement_snippet 
-- ------+----------+--------------+---------------+--------------+-------------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
