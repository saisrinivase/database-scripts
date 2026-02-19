/*
Purpose: Detect statements causing heavy temp file writes (sort/hash spill candidates).
Area: Performance Tuning
Usage: Requires pg_stat_statements; review work_mem and execution plans.
*/
SELECT
    queryid,
    calls,
    temp_blks_read,
    temp_blks_written,
    (temp_blks_written * current_setting('block_size')::bigint) AS temp_bytes_written,
    pg_size_pretty((temp_blks_written * current_setting('block_size')::bigint)::bigint) AS temp_written_pretty,
    mean_exec_time,
    left(query, 500) AS query_snippet
FROM pg_stat_statements
WHERE temp_blks_written > 0
ORDER BY temp_bytes_written DESC
LIMIT 100;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

       queryid       | calls | temp_blks_read | temp_blks_written | temp_bytes_written | temp_written_pretty |  mean_exec_time   |                            query_snippet                             
---------------------+-------+----------------+-------------------+--------------------+---------------------+-------------------+----------------------------------------------------------------------
 7127220720807722591 |     3 |            618 |               618 |            5062656 | 4944 kB             | 545.4183473333334 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)+
                     |       |                |                   |                    |                     |                   | SELECT                                                              +
                     |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                            +
                     |       |                |                   |                    |                     |                   |     round((random() * $3)::numeric, $4)                             +
                     |       |                |                   |                    |                     |                   | FROM generate_series($5, $6)
 7127220720807722591 |     3 |            618 |               618 |            5062656 | 4944 kB             | 557.2931383333333 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)+
                     |       |                |                   |                    |                     |                   | SELECT                                                              +
                     |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                            +
                     |       |                |                   |                    |                     |                   |     round((random() * $3)::numeric, $4)                             +
                     |       |                |                   |                    |                     |                   | FROM generate_series($5, $6)
(2 rows)


SAMPLE_OUTPUT_END */
