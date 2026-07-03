/*
PostgreSQL DBA Script: TOAST Compression Storage Policy
Purpose: Show TOAST-capable columns, storage policy, compression policy, and table-level TOAST footprint.
Area: Internals Deep Dive
Usage: Use when investigating wide rows, TOAST growth, CPU spent on compression/decompression, or LOB-heavy tables.
Sample Output: Columns include schema_name, table_name, column_name, storage_policy, compression_policy, toast_pct, diagnosis, action_hint.
Notes: Read-only diagnostic. Works on PostgreSQL 15+ in pgAdmin and psql.
*/
WITH column_policy AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        a.attname AS column_name,
        format_type(a.atttypid, a.atttypmod) AS data_type,
        CASE a.attstorage
            WHEN 'p' THEN 'PLAIN'
            WHEN 'm' THEN 'MAIN'
            WHEN 'x' THEN 'EXTENDED'
            WHEN 'e' THEN 'EXTERNAL'
            ELSE a.attstorage::text
        END AS storage_policy,
        CASE a.attcompression
            WHEN 'p' THEN 'pglz'
            WHEN 'l' THEN 'lz4'
            WHEN '\000' THEN 'default'
            ELSE a.attcompression::text
        END AS compression_policy,
        c.oid AS relid,
        c.reltoastrelid
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    JOIN pg_attribute a
      ON a.attrelid = c.oid
    WHERE c.relkind IN ('r', 'p', 'm')
      AND a.attnum > 0
      AND NOT a.attisdropped
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND a.attstorage IN ('m', 'x', 'e')
),
table_size AS (
    SELECT
        c.oid AS relid,
        pg_total_relation_size(c.oid) AS total_bytes,
        CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_bytes
    FROM pg_class c
)
SELECT
    p.schema_name,
    p.table_name,
    p.column_name,
    p.data_type,
    p.storage_policy,
    p.compression_policy,
    pg_size_pretty(s.total_bytes) AS table_total_size,
    pg_size_pretty(s.toast_bytes) AS toast_total_size,
    round(100.0 * s.toast_bytes / NULLIF(s.total_bytes, 0), 2) AS toast_pct,
    CASE
        WHEN s.toast_bytes >= 1024::bigint * 1024 * 1024 * 10
             AND s.toast_bytes >= s.total_bytes * 0.50 THEN 'TOAST_DOMINATES_TABLE'
        WHEN p.storage_policy = 'EXTERNAL' THEN 'COMPRESSION_DISABLED_FOR_COLUMN'
        WHEN p.compression_policy = 'lz4' THEN 'LZ4_COLUMN_COMPRESSION'
        WHEN p.compression_policy = 'pglz' THEN 'PGLZ_COLUMN_COMPRESSION'
        ELSE 'DEFAULT_TOAST_POLICY'
    END AS diagnosis,
    CASE
        WHEN s.toast_bytes >= 1024::bigint * 1024 * 1024 * 10
             AND s.toast_bytes >= s.total_bytes * 0.50 THEN 'Review access pattern, archive policy, compression method, and whether large attributes belong outside OLTP hot rows.'
        WHEN p.storage_policy = 'EXTERNAL' THEN 'Column is stored out-of-line without compression; use only when decompression CPU is worse than extra IO.'
        WHEN p.compression_policy = 'pglz' THEN 'For large compressible text/json payloads on PG15+, test LZ4 if the server was built with LZ4 support.'
        ELSE 'No immediate TOAST policy risk from catalog metadata; confirm with query and table growth evidence.'
    END AS action_hint
FROM column_policy p
JOIN table_size s
  ON s.relid = p.relid
ORDER BY s.toast_bytes DESC, toast_pct DESC NULLS LAST, p.schema_name, p.table_name, p.column_name;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | table_name | column_name | data_type | storage_policy | compression_policy | table_total_size | toast_total_size | toast_pct | diagnosis
-- public      | events     | payload     | jsonb      | EXTENDED       | lz4                | 120 GB           | 84 GB            | 70.00     | TOAST_DOMINATES_TABLE
-- SAMPLE_OUTPUT_END
