/*
Purpose: Detect chatty query patterns with many calls and tiny average row returns.
Area: Application Development and ORM Performance
Usage: Useful for API batching and data loader strategy tuning.
*/
SELECT
    queryid,
    calls,
    rows,
    CASE WHEN calls = 0 THEN NULL ELSE round(rows::numeric / calls, 4) END AS avg_rows_per_call,
    mean_exec_time,
    total_exec_time,
    left(query, 260) AS query_snippet
FROM pg_stat_statements
WHERE calls >= 5000
ORDER BY avg_rows_per_call ASC NULLS LAST, calls DESC
LIMIT 200;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

       queryid        |  calls  |  rows   | avg_rows_per_call |     mean_exec_time     |  total_exec_time   |                                                                 query_snippet                                                                 
----------------------+---------+---------+-------------------+------------------------+--------------------+-----------------------------------------------------------------------------------------------------------------------------------------------
  6097083398544187049 | 5332823 |       0 |            0.0000 | 0.00011446138958671586 |  610.4023310318215 | END
  4854991825702068830 | 5332823 |       0 |            0.0000 | 0.00011239772255708013 |   599.397160031148 | BEGIN
  -305747636952590102 | 5332823 | 5332823 |            1.0000 |   0.039258094757131864 | 209356.47065673055 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
  1144016440436625022 | 5332823 | 5332823 |            1.0000 |     3.8100014295381928 | 20318063.253471453 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
 -5371882943115234533 | 5332823 | 5332823 |            1.0000 |    0.08268383982104996 |  440938.2827256841 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
 -1078345578982625442 | 5332823 | 5332823 |            1.0000 |   0.006840656719152106 |  36480.01148695377 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
  3387776431457662738 | 5332823 | 5332823 |            1.0000 |   0.020229971087544072 | 107882.85510483896 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
  3689806360888379158 |  360000 |  360000 |            1.0000 |  0.0007802145055555485 |  280.8772220000928 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
  3689806360888379158 |  360000 |  360000 |            1.0000 |  0.0008264183916666604 |  297.5106209998934 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
  3481893718825960883 |    7109 |   35545 |            5.0000 |     2.8211766362357635 |  20055.74470699987 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                             +
                      |         |         |                   |                        |                    | FROM (SELECT                                                                                                                                 +
                      |         |         |                   |                        |                    |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",+
                      |         |         |                   |                        |                    |    (SELECT count(*) FROM pg_catalog.pg_s
(10 rows)


SAMPLE_OUTPUT_END */
