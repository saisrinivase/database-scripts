/*
Oracle DBA Script: Bind Sensitive SQL
Purpose: List bind-sensitive and bind-aware SQL with child cursor spread.
Area: Performance Tuning
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only cursor-cache check; depends on cursor aging and current shared pool contents.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN tablespace_name FORMAT A30
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN metric_name FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Bind Sensitive SQL

SELECT * FROM (
    SELECT inst_id,
           sql_id,
           COUNT(*) AS child_cursors,
           MAX(is_bind_sensitive) AS is_bind_sensitive,
           MAX(is_bind_aware) AS is_bind_aware,
           MAX(is_shareable) AS is_shareable,
           SUM(executions) AS executions,
           ROUND(SUM(elapsed_time)/1000000, 2) AS elapsed_seconds,
           MAX(parsing_schema_name) AS parsing_schema_name,
           SUBSTR(MAX(sql_text), 1, 180) AS sql_text_sample
    FROM gv$sql
    WHERE is_bind_sensitive = 'Y' OR is_bind_aware = 'Y'
    GROUP BY inst_id, sql_id
    ORDER BY child_cursors DESC, elapsed_seconds DESC
) WHERE ROWNUM <= 100;
