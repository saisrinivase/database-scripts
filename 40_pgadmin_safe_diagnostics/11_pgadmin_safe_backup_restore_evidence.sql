/*
PostgreSQL DBA Script: PgAdmin Safe Backup Restore Evidence
Purpose: pgAdmin-safe backup, restore, PITR, and DR evidence checklist.
Scope: WAL level, archiving configuration, archive status, replication slot risk, backup control functions, and optional custom backup history.
pgAdmin: Safe to run in Query Tool. Uses a temporary helper function only.
Sample output:
 evidence_area | check_name      | evidence_value | status  | diagnosis
---------------+-----------------+----------------+---------+-----------------------------
 pitr          | archive_mode    | on             | ok      | WAL archiving configured.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_backup_restore_evidence()
RETURNS TABLE (
    evidence_area text,
    check_name text,
    evidence_value text,
    status text,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 'pitr'::text, 'wal_level'::text, current_setting('wal_level')::text,
           CASE WHEN current_setting('wal_level') IN ('replica', 'logical') THEN 'ok' ELSE 'warning' END,
           'PITR and replication normally require replica or logical WAL level.'::text
    UNION ALL
    SELECT 'pitr', 'archive_mode', current_setting('archive_mode'),
           CASE WHEN current_setting('archive_mode') IN ('on', 'always') THEN 'ok' ELSE 'warning' END,
           'archive_mode should be on/always for continuous WAL archiving.'
    UNION ALL
    SELECT 'pitr', 'archive_command_configured',
           CASE WHEN nullif(current_setting('archive_command', true), '') IS NULL THEN 'empty' ELSE 'configured' END,
           CASE WHEN nullif(current_setting('archive_command', true), '') IS NULL THEN 'warning' ELSE 'ok' END,
           'Empty archive_command means WAL archiving is not actually shipping files.'
    UNION ALL
    SELECT 'archiver', 'failed_count', failed_count::text,
           CASE WHEN failed_count > 0 THEN 'critical' ELSE 'ok' END,
           'Archive failures must be zero for reliable PITR.'
    FROM pg_stat_archiver
    UNION ALL
    SELECT 'archiver', 'last_failed_wal', coalesce(last_failed_wal, 'none'),
           CASE WHEN failed_count > 0 THEN 'critical' ELSE 'ok' END,
           'Last failed WAL segment from pg_stat_archiver.'
    FROM pg_stat_archiver
    UNION ALL
    SELECT 'archiver', 'last_archived_wal', coalesce(last_archived_wal, 'none'),
           CASE WHEN archived_count > 0 THEN 'ok' ELSE 'warning' END,
           'A recent archived WAL confirms archiving is active after workload generates WAL.'
    FROM pg_stat_archiver
    UNION ALL
    SELECT 'replication_slots', 'inactive_slots', count(*)::text,
           CASE WHEN count(*) > 0 THEN 'warning' ELSE 'ok' END,
           'Inactive slots can retain WAL and affect DR storage safety.'
    FROM pg_replication_slots
    WHERE active = false;

    IF to_regclass('dba_metrics.backup_restore_history') IS NOT NULL THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'custom_backup_history'::text,
                   coalesce(backup_type, 'unknown')::text,
                   coalesce(max(finished_at)::text, 'no finish time')::text,
                   CASE WHEN max(finished_at) > now() - interval '1 day' THEN 'ok' ELSE 'warning' END::text,
                   'Custom backup history table shows latest recorded backup/restore evidence.'::text
            FROM dba_metrics.backup_restore_history
            GROUP BY backup_type
        $sql$;
    ELSE
        RETURN QUERY
        SELECT 'custom_backup_history',
               'dba_metrics.backup_restore_history',
               'not_found',
               'info',
               'No custom backup evidence table found. Keep backup tool evidence outside PostgreSQL or create a DBA history table.';
    END IF;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_backup_restore_evidence()
ORDER BY evidence_area, check_name;

-- SAMPLE_OUTPUT_BEGIN
-- evidence_area | check_name   | evidence_value | status | diagnosis
-- --------------+--------------+----------------+--------+------------------------------
-- pitr          | archive_mode | on             | ok     | archive_mode should be on...
-- archiver      | failed_count | 0              | ok     | Archive failures must be zero...
-- SAMPLE_OUTPUT_END
