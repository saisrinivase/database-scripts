/*
PostgreSQL DBA Script: Generate Safe Explain For Top Queries
Purpose: Generate non-executing EXPLAIN command text for top plannable queries from pg_stat_statements.
Area: Execution Plans
Usage: Requires pg_stat_statements. Replace bind placeholders before use. Add ANALYZE only for a statement proven safe to execute in the chosen environment.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Generated commands intentionally omit ANALYZE because EXPLAIN ANALYZE executes SELECT and DML statements.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    query AS query_text,
    CASE
        WHEN query ~* '^\s*(select|with|insert|update|delete|merge)(\s|$)'
        THEN format(
            '/* queryid=%s; NON_EXECUTING */ EXPLAIN (VERBOSE, COSTS, SETTINGS, FORMAT TEXT) %s;',
            queryid,
            query
        )
        ELSE NULL
    END AS safe_explain_sql,
    CASE
        WHEN query !~* '^\s*(select|with|insert|update|delete|merge)(\s|$)'
            THEN 'UTILITY_OR_TRANSACTION_STATEMENT_NOT_GENERATED'
        WHEN query ~ '\$[0-9]+'
            THEN 'REPLACE_BIND_PLACEHOLDERS_BEFORE_EXPLAIN'
        ELSE 'NON_EXECUTING_EXPLAIN_READY; ADD_ANALYZE_ONLY_AFTER_EXECUTION_SAFETY_REVIEW'
    END AS safety_status
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 50;


-- SAMPLE_OUTPUT_BEGIN
-- queryid | calls | total_exec_time | query_text                         | safe_explain_sql                             | safety_status
-- --------+-------+-----------------+------------------------------------+----------------------------------------------+------------------------------------------
-- 12345   | 9000  | 88000.25        | SELECT * FROM orders WHERE id = $1 | /* NON_EXECUTING */ EXPLAIN (...) SELECT ... | REPLACE_BIND_PLACEHOLDERS_BEFORE_EXPLAIN
-- 67890   | 200   | 15000.00        | UPDATE orders SET status=$1 WHERE id=$2 | /* NON_EXECUTING */ EXPLAIN (...) UPDATE ... | REPLACE_BIND_PLACEHOLDERS_BEFORE_EXPLAIN
--
-- Never add ANALYZE to DML unless executing the change is intended and safely contained.
-- SAMPLE_OUTPUT_END
