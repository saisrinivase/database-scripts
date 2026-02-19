/*
Purpose: Identify tables approaching anti-wraparound vacuum risk.
Area: Vacuum and Bloat
Usage: Compare results with autovacuum_freeze_max_age settings.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    age(c.relfrozenxid) AS relfrozenxid_age,
    age(t.relfrozenxid) AS toast_relfrozenxid_age,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_class t
    ON t.oid = c.reltoastrelid
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY relfrozenxid_age DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | relfrozenxid_age | toast_relfrozenxid_age | total_size 
------------------+-------------------------+------------------+------------------------+------------
 perf             | tenants                 |          5333452 |                5333452 | 32 kB
 perf             | audit_log               |          5333442 |                5333442 | 24 kB
 perf             | documents               |          5333441 |                5333441 | 24 kB
 perf             | support_tickets         |          5333436 |                5333436 | 16 kB
 perf             | ticket_comments         |          5333435 |                5333435 | 16 kB
 perf             | notifications           |          5333434 |                5333434 | 16 kB
 perf             | jobs                    |          5333433 |                5333433 | 16 kB
 perf             | job_runs                |          5333432 |                5333432 | 16 kB
 perf             | users                   |          5333416 |                5333451 | 4720 kB
 perf             | products                |          5333415 |                5333450 | 2232 kB
 perf             | payments                |          5333414 |                        | 83 MB
 perf             | categories              |          5333413 |                5333449 | 96 kB
 perf             | product_categories      |          5333412 |                        | 2640 kB
 perf             | orders                  |          5333411 |                        | 75 MB
 perf             | order_items             |          5333411 |                        | 117 MB
 perf             | shipments               |          5333410 |                5333444 | 18 MB
 perf             | addresses               |          5333409 |                5333440 | 1576 kB
 perf             | app_events              |          5333409 |                5333443 | 95 MB
 perf             | sessions                |          5333408 |                        | 1344 kB
 perf             | feature_flags           |          5333407 |                5333438 | 120 kB
 perf             | inventory               |          5333406 |                        | 3416 kB
 public           | demo_users              |          5333388 |                5333389 | 4400 kB
 dba_metrics      | database_size_snapshots |              410 |                    410 | 16 kB
 dba_metrics      | table_size_snapshots    |              409 |                    409 | 48 kB
 dba_metrics      | index_size_snapshots    |              408 |                    408 | 56 kB
 dba_metrics      | connection_snapshots    |              407 |                    407 | 16 kB
 dba_metrics      | wal_snapshots           |              406 |                    406 | 16 kB
 migration_v1_lab | orders_no_pk            |               44 |                     45 | 872 kB
 migration_v1_lab | parent_accounts         |               39 |                     41 | 792 kB
 migration_v1_lab | child_transactions      |               38 |                        | 11 MB
 migration_v1_lab | product_catalog         |               36 |                     37 | 6032 kB
 migration_v1_lab | sales_orders            |               33 |                     33 | 128 kB
 migration_v1_lab | stale_stats_table       |               29 |                     31 | 7768 kB
 migration_v1_lab | dml_bloat_table         |               26 |                     10 | 4248 kB
(34 rows)


SAMPLE_OUTPUT_END */
