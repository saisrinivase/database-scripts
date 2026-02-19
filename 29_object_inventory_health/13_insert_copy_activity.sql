/*
Purpose: Monitor INSERT/COPY pressure using active COPY progress and table write counters.
Area: Object Inventory and Health
Usage: Run during load windows or ETL batches to identify ingest hotspots.
*/
SELECT
    'copy_progress'::text AS section,
    c.pid,
    c.datname,
    coalesce(format('%I.%I', n.nspname, r.relname), '(n/a)') AS relation_name,
    c.command,
    c.type,
    c.bytes_processed,
    c.bytes_total,
    c.tuples_processed
FROM pg_stat_progress_copy c
LEFT JOIN pg_class r ON r.oid = c.relid
LEFT JOIN pg_namespace n ON n.oid = r.relnamespace
UNION ALL
SELECT
    'table_write_counters'::text AS section,
    NULL::integer AS pid,
    current_database() AS datname,
    format('%I.%I', s.schemaname, s.relname) AS relation_name,
    'n_tup_ins=' || s.n_tup_ins::text AS command,
    'n_tup_upd=' || s.n_tup_upd::text AS type,
    s.n_tup_del::bigint AS bytes_processed,
    NULL::bigint AS bytes_total,
    s.n_mod_since_analyze::bigint AS tuples_processed
FROM pg_stat_user_tables s
ORDER BY section, bytes_processed DESC NULLS LAST, relation_name;
