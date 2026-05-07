/*
PostgreSQL DBA Script: Backup Pitr Configuration Health
Purpose: Validate backup/PITR configuration prerequisites and highlight gaps for recoverability.
Area: Backup, Restore, PITR, and DR
Usage: Run on primary and standby nodes; review STATUS and remediation.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH expected(name, recommended, details) AS (
    VALUES
        ('archive_mode', 'on/always', 'WAL archiving must be enabled for PITR.'),
        ('archive_command', 'non-empty', 'Archive command must successfully ship WAL files.'),
        ('archive_library', 'non-empty (optional alternative)', 'Alternative to archive_command in newer releases.'),
        ('wal_level', 'replica/logical', 'At least replica is required for replication and PITR.'),
        ('max_wal_senders', '>= 2', 'Support base backup and replicas without blocking one another.'),
        ('max_replication_slots', '>= 2', 'Slots improve WAL retention guarantees for replicas/consumers.'),
        ('wal_keep_size', '> 0 or use replication slots', 'Extra WAL retention safety net.'),
        ('hot_standby', 'on (for standby)', 'Required to serve read traffic on standby.'),
        ('restore_command', 'set on restore/standby', 'Required when replaying archived WAL during restore.')
),
settings AS (
    SELECT
        e.name,
        e.recommended,
        e.details,
        s.setting,
        s.source,
        s.unit
    FROM expected e
    LEFT JOIN pg_settings s
      ON s.name = e.name
),
checks AS (
    SELECT
        name AS parameter_name,
        coalesce(setting, '(not available on this version)') AS current_value,
        recommended,
        coalesce(source, '(n/a)') AS source,
        CASE
            WHEN name = 'archive_mode' AND setting IN ('on', 'always') THEN 'OK'
            WHEN name = 'archive_command'
                 AND coalesce((SELECT setting FROM settings WHERE name = 'archive_mode'), 'off') IN ('on', 'always')
                 AND coalesce(trim(setting), '') <> ''
                 AND trim(setting) <> '(disabled)' THEN 'OK'
            WHEN name = 'archive_library'
                 AND coalesce((SELECT setting FROM settings WHERE name = 'archive_mode'), 'off') IN ('on', 'always')
                 AND coalesce(trim(setting), '') <> '' THEN 'OK'
            WHEN name = 'wal_level' AND setting IN ('replica', 'logical') THEN 'OK'
            WHEN name = 'max_wal_senders' AND setting ~ '^[0-9]+$' AND setting::int >= 2 THEN 'OK'
            WHEN name = 'max_replication_slots' AND setting ~ '^[0-9]+$' AND setting::int >= 2 THEN 'OK'
            WHEN name = 'wal_keep_size' AND setting ~ '^[0-9]+$' AND setting::int > 0 THEN 'OK'
            WHEN name = 'hot_standby' AND pg_is_in_recovery() AND setting = 'on' THEN 'OK'
            WHEN name = 'hot_standby' AND NOT pg_is_in_recovery() THEN 'INFO'
            WHEN name = 'restore_command' AND NOT pg_is_in_recovery() THEN 'INFO'
            WHEN name = 'restore_command' AND pg_is_in_recovery() AND coalesce(trim(setting), '') <> '' THEN 'OK'
            ELSE 'GAP'
        END AS status,
        details AS rationale,
        CASE
            WHEN name = 'archive_command' AND coalesce(trim(setting), '') = '' THEN 'Set archive_command or archive_library and verify archive destination write access.'
            WHEN name = 'wal_keep_size' AND (setting IS NULL OR setting !~ '^[0-9]+$' OR setting::int = 0)
                THEN 'Set wal_keep_size or ensure replication slots are actively managed.'
            WHEN name = 'restore_command' AND pg_is_in_recovery() AND coalesce(trim(setting), '') = ''
                THEN 'Define restore_command on standby/restore target for WAL replay.'
            WHEN name = 'archive_mode' AND setting NOT IN ('on', 'always')
                THEN 'Enable archive_mode and restart if required.'
            ELSE 'No action or environment-specific.'
        END AS remediation
    FROM settings
)
SELECT
    current_database() AS database_name,
    CASE WHEN pg_is_in_recovery() THEN 'standby' ELSE 'primary' END AS node_role,
    parameter_name,
    current_value,
    recommended,
    source,
    status,
    rationale,
    remediation
FROM checks
ORDER BY
    CASE status WHEN 'GAP' THEN 1 WHEN 'INFO' THEN 2 ELSE 3 END,
    parameter_name;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  database_name | node_role |    parameter_name     | current_value |           recommended            | source  | status |                           rationale                            |                             remediation                             
-- ---------------+-----------+-----------------------+---------------+----------------------------------+---------+--------+----------------------------------------------------------------+---------------------------------------------------------------------
--  pgbench_test  | primary   | archive_command       | (disabled)    | non-empty                        | default | GAP    | Archive command must successfully ship WAL files.              | No action or environment-specific.
--  pgbench_test  | primary   | archive_library       |               | non-empty (optional alternative) | default | GAP    | Alternative to archive_command in newer releases.              | No action or environment-specific.
--  pgbench_test  | primary   | archive_mode          | off           | on/always                        | default | GAP    | WAL archiving must be enabled for PITR.                        | Enable archive_mode and restart if required.
--  pgbench_test  | primary   | wal_keep_size         | 0             | > 0 or use replication slots     | default | GAP    | Extra WAL retention safety net.                                | Set wal_keep_size or ensure replication slots are actively managed.
--  pgbench_test  | primary   | hot_standby           | on            | on (for standby)                 | default | INFO   | Required to serve read traffic on standby.                     | No action or environment-specific.
--  pgbench_test  | primary   | restore_command       |               | set on restore/standby           | default | INFO   | Required when replaying archived WAL during restore.           | No action or environment-specific.
--  pgbench_test  | primary   | max_replication_slots | 10            | >= 2                             | default | OK     | Slots improve WAL retention guarantees for replicas/consumers. | No action or environment-specific.
--  pgbench_test  | primary   | max_wal_senders       | 10            | >= 2                             | default | OK     | Support base backup and replicas without blocking one another. | No action or environment-specific.
--  pgbench_test  | primary   | wal_level             | replica       | replica/logical                  | default | OK     | At least replica is required for replication and PITR.         | No action or environment-specific.
-- (9 rows)
-- 
-- SAMPLE_OUTPUT_END

