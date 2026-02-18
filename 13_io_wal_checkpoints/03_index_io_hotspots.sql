/*
Purpose: Show indexes with the most block reads/hits to target tuning/rebuild reviews.
Area: I/O, WAL, and Checkpoints
Usage: High-read indexes may need design or maintenance review.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    indexrelname AS index_name,
    idx_blks_read,
    idx_blks_hit,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_statio_user_indexes
ORDER BY idx_blks_read DESC, idx_blks_hit DESC;
