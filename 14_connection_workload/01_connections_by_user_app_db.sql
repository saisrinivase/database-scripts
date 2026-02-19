/*
Purpose: Break down active connections by database, user, and application.
Area: Connection and Workload
Usage: Useful for pool sizing and workload attribution.
*/
SELECT
    datname AS database_name,
    usename AS user_name,
    application_name,
    state,
    count(*) AS connection_count
FROM pg_stat_activity
GROUP BY datname, usename, application_name, state
ORDER BY connection_count DESC, datname, usename, application_name;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

           database_name           | user_name | application_name | state  | connection_count 
-----------------------------------+-----------+------------------+--------+------------------
                                   |           |                  |        |                7
 appdb                             | saiendla  | dbvis            | idle   |                2
 postgres                          | saiendla  | dbvis            | idle   |                1
 script_validation_20260218_172749 | saiendla  | psql             | active |                1
                                   | saiendla  |                  |        |                1
(5 rows)


SAMPLE_OUTPUT_END */
