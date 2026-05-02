/*
MySQL DBA Script: Missing Fk Supporting Indexes
Purpose: Provide MySQL DBA diagnostics for missing fk supporting indexes.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Missing Fk Supporting Indexes') AS script_name;

WITH fk_cols AS (
  SELECT k.constraint_schema, k.table_name, k.constraint_name,
         GROUP_CONCAT(k.column_name ORDER BY k.ordinal_position) AS fk_columns
  FROM information_schema.key_column_usage k
  WHERE k.referenced_table_name IS NOT NULL
    AND k.constraint_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  GROUP BY k.constraint_schema, k.table_name, k.constraint_name
), idx_cols AS (
  SELECT table_schema, table_name, index_name,
         GROUP_CONCAT(column_name ORDER BY seq_in_index) AS index_columns
  FROM information_schema.statistics
  GROUP BY table_schema, table_name, index_name
)
SELECT f.constraint_schema AS table_schema, f.table_name, f.constraint_name, f.fk_columns
FROM fk_cols f
WHERE NOT EXISTS (
  SELECT 1 FROM idx_cols i
  WHERE i.table_schema=f.constraint_schema AND i.table_name=f.table_name AND i.index_columns LIKE CONCAT(f.fk_columns, '%')
)
ORDER BY table_schema, table_name;
