/*
Purpose: Show XID and multixact age by database to assess wraparound risk.
Area: Internals Deep Dive
Usage: Monitor regularly on high-write systems.
*/
SELECT
    datname AS database_name,
    age(datfrozenxid) AS xid_age,
    mxid_age(datminmxid) AS multixact_age,
    datconnlimit,
    datallowconn
FROM pg_database
ORDER BY xid_age DESC, multixact_age DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

           database_name           | xid_age | multixact_age | datconnlimit | datallowconn 
-----------------------------------+---------+---------------+--------------+--------------
 postgres                          | 5333478 |             0 |           -1 | t
 perf_test                         | 5333478 |             0 |           -1 | t
 template1                         | 5333478 |             0 |           -1 | t
 template0                         | 5333478 |             0 |           -1 | f
 appdb                             | 5333478 |             0 |           -1 | t
 hypopg_lab                        | 5333478 |             0 |           -1 | t
 pgbench_test                      | 5333478 |             0 |           -1 | t
 script_validation_20260218_172749 | 5333478 |             0 |           -1 | t
(8 rows)


SAMPLE_OUTPUT_END */
