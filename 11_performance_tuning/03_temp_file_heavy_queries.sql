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
