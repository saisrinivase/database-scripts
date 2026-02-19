/*
Purpose: List prepared transactions (2PC) and their age.
Area: Connection and Workload
Usage: Stale prepared transactions can block cleanup and hold locks.
*/
SELECT
    transaction,
    gid,
    prepared,
    owner,
    database,
    now() - prepared AS prepared_age
FROM pg_prepared_xacts
ORDER BY prepared_age DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 transaction | gid | prepared | owner | database | prepared_age 
-------------+-----+----------+-------+----------+--------------
(0 rows)


SAMPLE_OUTPUT_END */
