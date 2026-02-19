/*
Purpose: Find foreign keys without supporting indexes on referencing columns.
Area: High Speed Tuning
Usage: Missing FK indexes often cause DELETE/UPDATE slowdown on parent tables.
*/
WITH fk AS (
    SELECT
        c.oid AS constraint_oid,
        c.conname,
        c.conrelid,
        c.conkey,
        n.nspname AS schema_name,
        t.relname AS table_name
    FROM pg_constraint c
    JOIN pg_class t
        ON t.oid = c.conrelid
    JOIN pg_namespace n
        ON n.oid = t.relnamespace
    WHERE c.contype = 'f'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
fk_cols AS (
    SELECT
        f.constraint_oid,
        string_agg(quote_ident(a.attname), ', ' ORDER BY k.ord) AS fk_columns
    FROM fk f
    JOIN LATERAL unnest(f.conkey) WITH ORDINALITY AS k(attnum, ord)
        ON true
    JOIN pg_attribute a
        ON a.attrelid = f.conrelid
       AND a.attnum = k.attnum
    GROUP BY f.constraint_oid
),
idx AS (
    SELECT
        i.indrelid,
        i.indkey::smallint[] AS indkey,
        i.indisvalid,
        i.indisready
    FROM pg_index i
)
SELECT
    f.schema_name,
    f.table_name,
    f.conname AS foreign_key_name,
    c.fk_columns,
    format(
        'CREATE INDEX CONCURRENTLY %I ON %I.%I (%s);',
        'idx_' || f.table_name || '_' || replace(f.conname, ' ', '_'),
        f.schema_name,
        f.table_name,
        c.fk_columns
    ) AS suggested_index_sql
FROM fk f
JOIN fk_cols c
    ON c.constraint_oid = f.constraint_oid
WHERE NOT EXISTS (
    SELECT 1
    FROM idx
    WHERE idx.indrelid = f.conrelid
      AND idx.indisvalid
      AND idx.indisready
      AND idx.indkey[1:array_length(f.conkey, 1)] = f.conkey
)
ORDER BY f.schema_name, f.table_name, f.conname;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |     table_name     |          foreign_key_name           | fk_columns  |                                                           suggested_index_sql                                                            
------------------+--------------------+-------------------------------------+-------------+------------------------------------------------------------------------------------------------------------------------------------------
 migration_v1_lab | child_transactions | child_transactions_account_id_fkey  | account_id  | CREATE INDEX CONCURRENTLY idx_child_transactions_child_transactions_account_id_fkey ON migration_v1_lab.child_transactions (account_id);
 perf             | addresses          | addresses_user_id_fkey              | user_id     | CREATE INDEX CONCURRENTLY idx_addresses_addresses_user_id_fkey ON perf.addresses (user_id);
 perf             | categories         | categories_tenant_id_fkey           | tenant_id   | CREATE INDEX CONCURRENTLY idx_categories_categories_tenant_id_fkey ON perf.categories (tenant_id);
 perf             | job_runs           | job_runs_job_id_fkey                | job_id      | CREATE INDEX CONCURRENTLY idx_job_runs_job_runs_job_id_fkey ON perf.job_runs (job_id);
 perf             | notifications      | notifications_user_id_fkey          | user_id     | CREATE INDEX CONCURRENTLY idx_notifications_notifications_user_id_fkey ON perf.notifications (user_id);
 perf             | order_items        | order_items_product_id_fkey         | product_id  | CREATE INDEX CONCURRENTLY idx_order_items_order_items_product_id_fkey ON perf.order_items (product_id);
 perf             | orders             | orders_tenant_id_fkey               | tenant_id   | CREATE INDEX CONCURRENTLY idx_orders_orders_tenant_id_fkey ON perf.orders (tenant_id);
 perf             | product_categories | product_categories_category_id_fkey | category_id | CREATE INDEX CONCURRENTLY idx_product_categories_product_categories_category_id_fkey ON perf.product_categories (category_id);
 perf             | products           | products_tenant_id_fkey             | tenant_id   | CREATE INDEX CONCURRENTLY idx_products_products_tenant_id_fkey ON perf.products (tenant_id);
 perf             | sessions           | sessions_user_id_fkey               | user_id     | CREATE INDEX CONCURRENTLY idx_sessions_sessions_user_id_fkey ON perf.sessions (user_id);
 perf             | shipments          | shipments_order_id_fkey             | order_id    | CREATE INDEX CONCURRENTLY idx_shipments_shipments_order_id_fkey ON perf.shipments (order_id);
 perf             | support_tickets    | support_tickets_user_id_fkey        | user_id     | CREATE INDEX CONCURRENTLY idx_support_tickets_support_tickets_user_id_fkey ON perf.support_tickets (user_id);
 perf             | ticket_comments    | ticket_comments_ticket_id_fkey      | ticket_id   | CREATE INDEX CONCURRENTLY idx_ticket_comments_ticket_comments_ticket_id_fkey ON perf.ticket_comments (ticket_id);
 perf             | users              | users_tenant_id_fkey                | tenant_id   | CREATE INDEX CONCURRENTLY idx_users_users_tenant_id_fkey ON perf.users (tenant_id);
(14 rows)


SAMPLE_OUTPUT_END */
