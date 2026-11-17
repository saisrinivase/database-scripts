/*
PostgreSQL DBA Script: N Plus One Query Candidates
Purpose: Flag very frequently called, short statements (common N+1 query symptom).
Area: Application Development and ORM Performance
Usage: Requires pg_stat_statements; validate in application traces.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

SELECT
    queryid,
    calls,
    mean_exec_time,
    total_exec_time,
    rows,
    CASE
        WHEN calls >= 50000 AND mean_exec_time < 5 THEN 'Strong N+1 candidate'
        WHEN calls >= 10000 AND mean_exec_time < 10 THEN 'Candidate'
        ELSE 'Observe'
    END AS recommendation,
    query AS query_snippet
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |     mean_exec_time     |   total_exec_time    |  rows   |    recommendation    |                                                                                                                  query_snippet                                                                                                                   
-- ----------------------+---------+------------------------+----------------------+---------+----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  -5371882943115234533 | 5332823 |    0.08268383982104996 |    440938.2827256841 | 5332823 | Strong N+1 candidate | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 5332823 |   0.039258094757131864 |   209356.47065673055 | 5332823 | Strong N+1 candidate | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 5332823 |   0.020229971087544072 |   107882.85510483896 | 5332823 | Strong N+1 candidate | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--   4854991825702068830 | 5332823 | 0.00011239772255708013 |     599.397160031148 |       0 | Strong N+1 candidate | BEGIN
--   6097083398544187049 | 5332823 | 0.00011446138958671586 |    610.4023310318215 |       0 | Strong N+1 candidate | END
--  -1078345578982625442 | 5332823 |   0.006840656719152106 |    36480.01148695377 | 5332823 | Strong N+1 candidate | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   1144016440436625022 | 5332823 |     3.8100014295381928 |   20318063.253471453 | 5332823 | Strong N+1 candidate | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--   3689806360888379158 | 1120000 |   0.001003262473214298 |   1123.6539700004319 | 1120000 | Strong N+1 candidate | SELECT $2 FROM ONLY "migration_v2_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   3689806360888379158 |  480000 |  0.0007798826791666557 |    374.3436859998984 |  480000 | Strong N+1 candidate | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   3689806360888379158 |  360000 |  0.0008264183916666604 |    297.5106209998934 |  360000 | Strong N+1 candidate | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   3481893718825960883 |    7109 |     2.8211766362357635 |    20055.74470699987 |   35545 | Observe              | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                +
--                       |         |                        |                      |         |                      | FROM (SELECT                                                                                                                                                                                                                                    +
--                       |         |                        |                      |         |                      |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                   +
--                       |         |                        |                      |         |                      |    (SELECT count(*) 
--   6967984576543786987 |    1310 |  0.0017542320610687042 |   2.2980440000000093 |    1940 | Observe              | SELECT * FROM pg_catalog.unnest($1) WITH ORDINALITY
--   4640742184386830055 |      64 |     1.7936862343750006 |   114.79591899999996 |      64 | Observe              | SELECT set_config($1,$2,$3) FROM pg_show_all_settings() WHERE name = $4
--  -4159615726391246039 |      64 |    0.12163867187499999 |    7.784874999999997 |      64 | Observe              | SELECT                                                                                                                                                                                                                                          +
--                       |         |                        |                      |         |                      |              gss_authenticated, encrypted                                                                                                                                                                                                       +
--                       |         |                        |                      |         |                      |         FROM                                                                                                                                                                                                                                    +
--                       |         |                        |                      |         |                      |             pg_catalog.pg_stat_gssapi                                                                                                                                                                                                           +
--                       |         |                        |                      |         |                      |         WHERE pid = pg_backend_pid()
--   5052781666619390961 |      64 |         0.071800265625 |    4.595217000000001 |      64 | Observe              | SELECT                                                                                                                                                                                                                                          +
--                       |         |                        |                      |         |                      |             roles.oid as id, roles.rolname as name,                                                                                                                                                                                             +
--                       |         |                        |                      |         |                      |             roles.rolsuper as is_superuser,                                                                                                                                                                                                     +
--                       |         |                        |                      |         |                      |             CASE WHEN roles.rolsuper THEN $1 ELSE roles.rolcreaterole END as                                                                                                                                                                    +
--                       |         |                        |                      |         |                      |             can_create_role,                                                                                                                                                                                                                    +
--                       |         |                        |                      |         |                      |             CASE WHEN roles.rol
--  -8370928913120278298 |      64 |  0.0046777187500000005 |  0.29937399999999986 |       0 | Observe              | SET client_min_messages=$1
--  -6043488156747258108 |      64 |   0.019471999999999996 |   1.2462079999999995 |      64 | Observe              | SELECT                                                                                                                                                                                                                                          +
--                       |         |                        |                      |         |                      |     db.oid as did, db.datname, db.datallowconn,                                                                                                                                                                                                 +
--                       |         |                        |                      |         |                      |     pg_encoding_to_char(db.encoding) AS serverencoding,                                                                                                                                                                                         +
--                       |         |                        |                      |         |                      |     has_database_privilege(db.oid, $1) as cancreate,                                                                                                                                                                                            +
--                       |         |                        |                      |         |                      |     datistemplate                                                                                                                                                                                                                               +
--                       |         |                        |                      |         |                      | FROM                                                                                                                                                                                                                                            +
--                       |         |                        |                      |         |                      |     pg_catalog.pg_database db                                                                                                                                                                                                                   +
--                       |         |                        |                      |         |                      | WHERE db.datname = curr
--   4359259187362990377 |      64 |  0.0032382812500000007 |  0.20724999999999993 |       0 | Observe              | SET client_encoding=$1
--  -8873911804314169340 |      64 |         0.021634765625 |   1.3846249999999996 |       0 | Observe              | SET DateStyle=$1
--    -86323926068950410 |      64 |   0.005264437500000001 |  0.33692400000000006 |      64 | Observe              | SELECT version()
--  -8370928913120278298 |      63 |   0.008288349206349205 |             0.522166 |       0 | Observe              | SET client_min_messages=$1
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
