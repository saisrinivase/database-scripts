/*
PostgreSQL DBA Script: Top Queries By Mean Exec Time
Purpose: Find high-latency application SQL by average execution time, with percentage contribution and noise filtering.
Area: Performance Tuning
Usage: Requires pg_stat_statements. Optional runtime filters without editing this file:
       SELECT set_config('pgdiag.min_calls','50',false);
       SELECT set_config('pgdiag.max_rows','10',false);
       SELECT set_config('pgdiag.min_exec_pct','30',false); -- optional: show only SQL >= 30% of total exec time
       SELECT set_config('pgdiag.query_filter','invoice',false);
       SELECT set_config('pgdiag.include_noise','on',false);
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH params AS (
    SELECT
        coalesce(nullif(current_setting('pgdiag.min_calls', true), '')::bigint, 50) AS min_calls,
        coalesce(nullif(current_setting('pgdiag.max_rows', true), '')::integer, 10) AS max_rows,
        coalesce(nullif(current_setting('pgdiag.min_exec_pct', true), '')::numeric, 0) AS min_exec_pct,
        coalesce(nullif(current_setting('pgdiag.query_filter', true), ''), '') AS query_filter,
        coalesce(nullif(current_setting('pgdiag.include_noise', true), '')::boolean, false) AS include_noise
),
base AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        s.min_exec_time,
        s.max_exec_time,
        s.stddev_exec_time,
        s.rows,
        regexp_replace(s.query, '\s+', ' ', 'g') AS query_snippet
    FROM pg_stat_statements s
    CROSS JOIN params p
    WHERE s.calls >= p.min_calls
      AND (p.query_filter = '' OR s.query ILIKE '%' || p.query_filter || '%')
      AND (
          p.include_noise
          OR s.query !~* '^\s*(begin|commit|end|rollback|set|show|reset|discard|deallocate|analyze|vacuum)\b'
      )
      AND (
          p.include_noise
          OR s.query !~* '(pg_catalog|information_schema|pg_stat_activity|pg_show_all_settings|pg_settings|pg_backend_pid\(\)|set_config\()'
      )
),
totals AS (
    SELECT sum(total_exec_time) AS all_exec_ms, sum(calls) AS all_calls FROM base
)
SELECT
    row_number() OVER (ORDER BY b.mean_exec_time DESC) AS rank_by_mean_time,
    b.queryid,
    b.calls,
    round((100.0 * b.calls / NULLIF(t.all_calls, 0))::numeric, 2) AS pct_calls,
    round(b.total_exec_time::numeric, 2) AS total_exec_ms,
    round((100.0 * b.total_exec_time / NULLIF(t.all_exec_ms, 0))::numeric, 2) AS pct_total_exec_time,
    round(b.mean_exec_time::numeric, 4) AS mean_exec_ms,
    round(b.min_exec_time::numeric, 4) AS min_exec_ms,
    round(b.max_exec_time::numeric, 4) AS max_exec_ms,
    round(b.stddev_exec_time::numeric, 4) AS stddev_exec_ms,
    b.rows,
    round((b.rows::numeric / NULLIF(b.calls, 0)), 2) AS rows_per_call,
    CASE
        WHEN b.calls < 100 THEN 'High latency but low frequency; validate business impact before tuning.'
        WHEN b.stddev_exec_time > b.mean_exec_time THEN 'Latency varies; check parameter skew, plan instability, locks, and cache effects.'
        ELSE 'Consistent high latency; inspect EXPLAIN plan and indexing/statistics.'
    END AS recommended_action,
    b.query_snippet
FROM base b
CROSS JOIN totals t
WHERE round((100.0 * b.total_exec_time / NULLIF(t.all_exec_ms, 0))::numeric, 2) >= (SELECT min_exec_pct FROM params)
ORDER BY b.mean_exec_time DESC
LIMIT (SELECT max_rows FROM params);




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |   total_exec_time   |     mean_exec_time     |     min_exec_time     |    max_exec_time    |   stddev_exec_time    |  rows   |                                                                         query_snippet                                                                          
-- ----------------------+---------+---------------------+------------------------+-----------------------+---------------------+-----------------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 |  20318063.253471453 |     3.8100014295381928 |  0.005416000000000001 |         8598.566083 |     92.32002420399405 | 5332823 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--   3481893718825960883 |    7109 |   20055.74470699987 |     2.8211766362357635 |              0.191207 |         8578.898084 |    117.82179113781538 |   35545 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                              +
--                       |         |                     |                        |                       |                     |                       |         | FROM (SELECT                                                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                 +
--                       |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",+
--                       |         |                     |                        |                       |                     |                       |         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_da
--   4640742184386830055 |      63 |          155.489831 |     2.4680925555555544 |              1.108875 |            9.759916 |    1.0937281720904906 |      63 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
--   4640742184386830055 |      64 |  114.79591899999996 |     1.7936862343750006 |              1.019208 |            2.651126 |    0.5239858325949681 |      64 | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
--  -4159615726391246039 |      63 |           10.248413 |    0.16267322222222222 |              0.076375 | 0.24416800000000002 |   0.04069454089219839 |      63 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |              gss_authenticated, encrypted                                                                                                                     +
--                       |         |                     |                        |                       |                     |                       |         |         FROM                                                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             pg_catalog.pg_stat_gssapi                                                                                                                         +
--                       |         |                     |                        |                       |                     |                       |         |         WHERE pid = pg_backend_pid()
--  -4159615726391246039 |      64 |   7.784874999999997 |    0.12163867187499999 |              0.079583 |            0.218584 |   0.02868252611731504 |      64 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |              gss_authenticated, encrypted                                                                                                                     +
--                       |         |                     |                        |                       |                     |                       |         |         FROM                                                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             pg_catalog.pg_stat_gssapi                                                                                                                         +
--                       |         |                     |                        |                       |                     |                       |         |         WHERE pid = pg_backend_pid()
--   5052781666619390961 |      63 |   6.369126000000001 |    0.10109723809523813 |              0.042834 |            0.705084 |   0.08493532944890547 |      63 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |             roles.oid as id, roles.rolname as name,                                                                                                           +
--                       |         |                     |                        |                       |                     |                       |         |             roles.rolsuper as is_superuser,                                                                                                                   +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN roles.rolsuper THEN $1 ELSE roles.rolcreaterole END as                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             can_create_role,                                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN roles.rolsuper THEN $2                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             ELSE roles.rolcreatedb END as can_create_db,                                                                                                      +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN $3=ANY(ARRAY(WITH RECURSIVE cte AS (                                                                                                    +
--                       |         |                     |                        |                       |                     |                       |         |             SELECT pg_roles.oid,pg_roles.rolname FROM pg_roles                                                                                                +
--                       |         |                     |                        |                       |                     |                       |         |                 WHERE pg_roles.oid = roles.oid                                                                                                                +
--                       |         |                     |                        |                       |                     |                       |         |             UNION AL
--  -5371882943115234533 | 5332823 |   440938.2827256841 |    0.08268383982104996 | 0.0018750000000000001 |            858.2885 |    2.0963843383810876 | 5332823 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   5052781666619390961 |      64 |   4.595217000000001 |         0.071800265625 |              0.039375 |            0.159916 |   0.01953957885632565 |      64 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |             roles.oid as id, roles.rolname as name,                                                                                                           +
--                       |         |                     |                        |                       |                     |                       |         |             roles.rolsuper as is_superuser,                                                                                                                   +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN roles.rolsuper THEN $1 ELSE roles.rolcreaterole END as                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             can_create_role,                                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN roles.rolsuper THEN $2                                                                                                                  +
--                       |         |                     |                        |                       |                     |                       |         |             ELSE roles.rolcreatedb END as can_create_db,                                                                                                      +
--                       |         |                     |                        |                       |                     |                       |         |             CASE WHEN $3=ANY(ARRAY(WITH RECURSIVE cte AS (                                                                                                    +
--                       |         |                     |                        |                       |                     |                       |         |             SELECT pg_roles.oid,pg_roles.rolname FROM pg_roles                                                                                                +
--                       |         |                     |                        |                       |                     |                       |         |                 WHERE pg_roles.oid = roles.oid                                                                                                                +
--                       |         |                     |                        |                       |                     |                       |         |             UNION AL
--   -305747636952590102 | 5332823 |  209356.47065673055 |   0.039258094757131864 |              0.002249 |          523.314959 |     0.625514976433878 | 5332823 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--  -8873911804314169340 |      63 |  2.2035439999999995 |   0.034976888888888905 |              0.013792 |            0.271792 |   0.03103066123533206 |       0 | SET DateStyle=$1
--  -6043488156747258108 |      63 |            1.806081 |    0.02866795238095238 |              0.014167 |             0.04675 |  0.006765567321977412 |      63 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |     db.oid as did, db.datname, db.datallowconn,                                                                                                               +
--                       |         |                     |                        |                       |                     |                       |         |     pg_encoding_to_char(db.encoding) AS serverencoding,                                                                                                       +
--                       |         |                     |                        |                       |                     |                       |         |     has_database_privilege(db.oid, $1) as cancreate,                                                                                                          +
--                       |         |                     |                        |                       |                     |                       |         |     datistemplate                                                                                                                                             +
--                       |         |                     |                        |                       |                     |                       |         | FROM                                                                                                                                                          +
--                       |         |                     |                        |                       |                     |                       |         |     pg_catalog.pg_database db                                                                                                                                 +
--                       |         |                     |                        |                       |                     |                       |         | WHERE db.datname = current_database()
--  -8873911804314169340 |      64 |  1.3846249999999996 |         0.021634765625 |              0.011916 |             0.03275 |  0.004733740083638238 |       0 | SET DateStyle=$1
--   3387776431457662738 | 5332823 |  107882.85510483896 |   0.020229971087544072 |              0.000791 |         4867.976875 |    2.4970450599666827 | 5332823 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -6043488156747258108 |      64 |  1.2462079999999995 |   0.019471999999999996 |              0.012208 |            0.088917 |  0.009862842612870288 |      64 | SELECT                                                                                                                                                        +
--                       |         |                     |                        |                       |                     |                       |         |     db.oid as did, db.datname, db.datallowconn,                                                                                                               +
--                       |         |                     |                        |                       |                     |                       |         |     pg_encoding_to_char(db.encoding) AS serverencoding,                                                                                                       +
--                       |         |                     |                        |                       |                     |                       |         |     has_database_privilege(db.oid, $1) as cancreate,                                                                                                          +
--                       |         |                     |                        |                       |                     |                       |         |     datistemplate                                                                                                                                             +
--                       |         |                     |                        |                       |                     |                       |         | FROM                                                                                                                                                          +
--                       |         |                     |                        |                       |                     |                       |         |     pg_catalog.pg_database db                                                                                                                                 +
--                       |         |                     |                        |                       |                     |                       |         | WHERE db.datname = current_database()
--  -8370928913120278298 |      63 |            0.522166 |   0.008288349206349205 |              0.003542 |            0.012292 | 0.0020357493621161993 |       0 | SET client_min_messages=$1
--    -86323926068950410 |      63 |  0.5077889999999999 |   0.008060142857142856 |              0.003584 |            0.011334 | 0.0020737319158842388 |      63 | SELECT version()
--  -1078345578982625442 | 5332823 |   36480.01148695377 |   0.006840656719152106 |              0.001209 |  13.366708999999998 |   0.05010911945496172 | 5332823 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--    -86323926068950410 |      64 | 0.33692400000000006 |   0.005264437500000001 |              0.003166 |            0.009417 |  0.001350254199157977 |      64 | SELECT version()
--   4359259187362990377 |      63 |            0.300123 |   0.004763857142857143 |               0.00175 |            0.015416 | 0.0018148649331626808 |       0 | SET client_encoding=$1
--  -8370928913120278298 |      64 | 0.29937399999999986 |  0.0046777187500000005 |              0.002875 |            0.007458 | 0.0011493660272726169 |       0 | SET client_min_messages=$1
--   4359259187362990377 |      64 | 0.20724999999999993 |  0.0032382812500000007 |              0.001291 |              0.0055 | 0.0008873322283104775 |       0 | SET client_encoding=$1
--   6967984576543786987 |    1310 |  2.2980440000000093 |  0.0017542320610687042 |              0.000791 |            0.774084 |  0.021364221559189062 |    1940 | SELECT * FROM pg_catalog.unnest($1) WITH ORDINALITY
--   3689806360888379158 | 1120000 |  1123.6539700004319 |   0.001003262473214298 |              0.000458 |            8.278041 |  0.008895060092570838 | 1120000 | SELECT $2 FROM ONLY "migration_v2_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   3689806360888379158 |  360000 |   297.5106209998934 |  0.0008264183916666604 |              0.000458 |  2.1451249999999997 | 0.0050451679583725555 |  360000 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   3689806360888379158 |  480000 |   374.3436859998984 |  0.0007798826791666557 |              0.000458 |            0.386375 | 0.0014889282231169228 |  480000 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   6097083398544187049 | 5332823 |   610.4023310318215 | 0.00011446138958671586 |                     0 |            5.248292 |   0.00335278765645261 |       0 | END
--   4854991825702068830 | 5332823 |    599.397160031148 | 0.00011239772255708013 |                     0 |             3.68725 | 0.0021783571257651454 |       0 | BEGIN
-- (28 rows)
-- 
-- SAMPLE_OUTPUT_END
