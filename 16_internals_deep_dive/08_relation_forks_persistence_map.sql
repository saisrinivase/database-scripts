/*
PostgreSQL DBA Script: Relation Forks Persistence Map
Purpose: Map heap/index/TOAST relation forks and persistence to explain physical storage, VM/FSM growth, and unlogged init forks.
Area: Internals Deep Dive
Usage: Use for storage internals, unexplained disk growth, unlogged table review, and fork-level capacity checks.
Sample Output: Columns include schema_name, relation_name, relkind_label, persistence_label, main_bytes, fsm_bytes, vm_bytes, init_bytes, toast_bytes.
Notes: Read-only diagnostic. Works on PostgreSQL 15+ in pgAdmin and psql.
*/
WITH rels AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS relation_name,
        c.oid,
        c.relkind,
        c.relpersistence,
        c.reltoastrelid,
        c.reltablespace
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'p', 'm', 'i', 't')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    schema_name,
    relation_name,
    CASE relkind
        WHEN 'r' THEN 'ordinary_table'
        WHEN 'p' THEN 'partitioned_table'
        WHEN 'm' THEN 'materialized_view'
        WHEN 'i' THEN 'index'
        WHEN 't' THEN 'toast_table'
        ELSE relkind::text
    END AS relkind_label,
    CASE relpersistence
        WHEN 'p' THEN 'permanent'
        WHEN 'u' THEN 'unlogged'
        WHEN 't' THEN 'temporary'
        ELSE relpersistence::text
    END AS persistence_label,
    COALESCE(NULLIF(pg_tablespace_location(reltablespace), ''), 'database_default') AS tablespace_location,
    pg_relation_filenode(oid) AS relfilenode,
    pg_relation_filepath(oid) AS relation_filepath,
    pg_relation_size(oid, 'main') AS main_bytes,
    pg_relation_size(oid, 'fsm') AS fsm_bytes,
    pg_relation_size(oid, 'vm') AS vm_bytes,
    pg_relation_size(oid, 'init') AS init_bytes,
    CASE WHEN reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(reltoastrelid) END AS toast_bytes,
    pg_total_relation_size(oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(oid)) AS total_size,
    CASE
        WHEN relpersistence = 'u' THEN 'UNLOGGED_DATA_LOST_AFTER_CRASH_REINIT'
        WHEN pg_relation_size(oid, 'fsm') > pg_relation_size(oid, 'main') * 0.10 THEN 'HIGH_FSM_RELATIVE_TO_MAIN'
        WHEN pg_relation_size(oid, 'vm') = 0 AND pg_relation_size(oid, 'main') > 1024::bigint * 1024 * 1024 THEN 'LARGE_RELATION_WITH_EMPTY_VM'
        ELSE 'NORMAL_FORK_PROFILE'
    END AS diagnosis,
    CASE
        WHEN relpersistence = 'u' THEN 'Confirm this relation can be rebuilt after crash or failover; unlogged tables do not stream data through WAL.'
        WHEN pg_relation_size(oid, 'fsm') > pg_relation_size(oid, 'main') * 0.10 THEN 'Review churn, fillfactor, bloat, and VACUUM behavior.'
        WHEN pg_relation_size(oid, 'vm') = 0 AND pg_relation_size(oid, 'main') > 1024::bigint * 1024 * 1024 THEN 'Review vacuum coverage; low visibility map coverage can reduce index-only scan benefit.'
        ELSE 'No fork-level action from size profile alone.'
    END AS action_hint
FROM rels
ORDER BY total_bytes DESC, schema_name, relation_name
LIMIT 200;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | relation_name | relkind_label | persistence_label | main_bytes | fsm_bytes | vm_bytes | init_bytes | diagnosis
-- public      | orders        | ordinary_table| permanent         | 1073741824 | 1048576   | 262144   | 0          | NORMAL_FORK_PROFILE
-- SAMPLE_OUTPUT_END
