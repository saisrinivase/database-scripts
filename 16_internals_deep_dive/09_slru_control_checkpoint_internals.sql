/*
PostgreSQL DBA Script: SLRU Control Checkpoint Internals
Purpose: Review SLRU activity, checkpoint control data, and cluster state that affect XID, multixact, notify, and subtransaction internals.
Area: Internals Deep Dive
Usage: Use during wraparound, multixact, high commit/rollback, subtransaction, or checkpoint-pressure investigations.
Sample Output: First result shows control checkpoint state; second result ranks pg_stat_slru counters.
Notes: Read-only diagnostic. Requires PostgreSQL 15+ built-in control functions/views.
*/
SELECT
    'control_checkpoint' AS section,
    c.checkpoint_lsn,
    c.redo_lsn,
    c.timeline_id,
    c.prev_timeline_id,
    c.full_page_writes,
    c.next_xid,
    c.next_oid,
    c.next_multixact_id,
    c.next_multi_offset,
    c.oldest_xid,
    c.oldest_xid_dbid,
    c.oldest_multi_xid,
    c.oldest_multi_dbid,
    s.pg_control_version,
    s.catalog_version_no,
    s.system_identifier,
    s.pg_control_last_modified,
    CASE
        WHEN age(c.oldest_xid) > 1500000000 THEN 'CRITICAL_XID_WRAPAROUND_PROXIMITY'
        WHEN age(c.oldest_xid) > 1000000000 THEN 'WARN_XID_WRAPAROUND_PROXIMITY'
        WHEN mxid_age(c.oldest_multi_xid) > 1000000000 THEN 'WARN_MULTI_XACT_AGE'
        ELSE 'CONTROL_STATE_OK'
    END AS diagnosis
FROM pg_control_checkpoint() c
CROSS JOIN pg_control_system() s;

SELECT
    'slru_activity' AS section,
    name,
    blks_zeroed,
    blks_hit,
    blks_read,
    blks_written,
    blks_exists,
    flushes,
    truncates,
    stats_reset,
    round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS slru_hit_pct,
    CASE
        WHEN name IN ('Subtrans', 'MultiXactMember', 'MultiXactOffset') AND blks_read > blks_hit THEN 'SLRU_READ_PRESSURE_REVIEW_SUBTRANSACTIONS_OR_MULTIXACT'
        WHEN truncates = 0 AND name IN ('MultiXactMember', 'MultiXactOffset') THEN 'NO_RECENT_MULTIXACT_TRUNCATION_VISIBLE'
        WHEN blks_written > blks_hit THEN 'SLRU_WRITE_PRESSURE'
        ELSE 'SLRU_PROFILE_NORMAL'
    END AS diagnosis,
    CASE
        WHEN name = 'Subtrans' AND blks_read > blks_hit THEN 'Look for deep savepoint/subtransaction patterns in application code.'
        WHEN name LIKE 'MultiXact%' AND blks_read > blks_hit THEN 'Inspect foreign-key locking, shared row locks, and autovacuum multixact freeze progress.'
        WHEN name IN ('Xact', 'CommitTs') AND blks_written > blks_hit THEN 'Correlate with commit rate, checkpoint pressure, and storage latency.'
        ELSE 'Track trend over time; single snapshot is directional.'
    END AS action_hint
FROM pg_stat_slru
ORDER BY (blks_read + blks_written) DESC, name;

-- SAMPLE_OUTPUT_BEGIN
-- section            | checkpoint_lsn | next_xid | oldest_xid | diagnosis
-- control_checkpoint | 0/12345678     | 0:12345  | 1000       | CONTROL_STATE_OK
--
-- section       | name     | blks_hit | blks_read | slru_hit_pct | diagnosis
-- slru_activity | Subtrans | 100000   | 25        | 99.98        | SLRU_PROFILE_NORMAL
-- SAMPLE_OUTPUT_END
