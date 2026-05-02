/*
MySQL DBA Script: Statement Infra Tier Classification
Purpose: Provide MySQL DBA diagnostics for statement infra tier classification.
Area: Sql Resource Attribution
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Statement Infra Tier Classification') AS script_name;

SELECT schema_name, digest,
       CASE
         WHEN sum_rows_examined > sum_rows_sent * 100 THEN 'ROW_SCAN_HEAVY'
         WHEN sum_created_tmp_disk_tables > 0 THEN 'TEMP_DISK_HEAVY'
         WHEN sum_no_index_used > 0 THEN 'INDEXING_RISK'
         ELSE 'MIXED'
       END AS infra_tier,
       count_star, sum_rows_examined, sum_created_tmp_disk_tables, LEFT(digest_text,200) AS digest_text
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 100;
