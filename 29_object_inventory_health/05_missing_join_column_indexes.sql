/*
Purpose: Suggest indexes for likely join columns (id/key-style columns) under scan pressure.
Area: Object Inventory and Health
Usage: Heuristic-only; validate each candidate with EXPLAIN (ANALYZE, BUFFERS).
*/
WITH table_pressure AS (
    SELECT
        st.relid,
        st.schemaname AS schema_name,
        st.relname AS table_name,
        st.seq_scan,
        st.idx_scan,
        st.seq_tup_read,
        c.reltuples::bigint AS est_rows
    FROM pg_stat_user_tables st
    JOIN pg_class c ON c.oid = st.relid
    WHERE c.reltuples >= 10000
      AND st.seq_tup_read >= 100000
      AND st.seq_scan >= st.idx_scan
),
joinish_columns AS (
    SELECT
        p.relid,
        p.schema_name,
        p.table_name,
        a.attnum,
        a.attname AS column_name,
        p.est_rows,
        p.seq_scan,
        p.idx_scan,
        p.seq_tup_read,
        s.n_distinct
    FROM table_pressure p
    JOIN pg_attribute a
      ON a.attrelid = p.relid
     AND a.attnum > 0
     AND NOT a.attisdropped
    LEFT JOIN pg_stats s
      ON s.schemaname = p.schema_name
     AND s.tablename = p.table_name
     AND s.attname = a.attname
    WHERE a.attname ~* '(^id$|_id$|_key$|_code$)'
),
missing AS (
    SELECT j.*
    FROM joinish_columns j
    WHERE NOT EXISTS (
        SELECT 1
        FROM pg_index i
        WHERE i.indrelid = j.relid
          AND i.indisvalid
          AND i.indisready
          AND (i.indkey::smallint[])[array_lower(i.indkey::smallint[], 1)] = j.attnum
    )
)
SELECT
    schema_name,
    table_name,
    column_name,
    est_rows,
    seq_scan,
    idx_scan,
    seq_tup_read,
    n_distinct,
    format(
        'CREATE INDEX CONCURRENTLY %I ON %I.%I (%I);',
        left('idx_' || table_name || '_' || column_name, 60),
        schema_name,
        table_name,
        column_name
    ) AS suggested_index_sql
FROM missing
ORDER BY seq_tup_read DESC, est_rows DESC, schema_name, table_name, column_name;
