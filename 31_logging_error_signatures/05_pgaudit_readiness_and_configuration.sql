/*
PostgreSQL DBA Script: pgAudit Readiness and Configuration
Purpose: Verify pgAudit package availability, database installation, preload status, and active audit GUCs without failing when pgAudit is absent.
Area: Logging and Error Signatures
Usage: Run in every audited database. Run on the writer and separately on readers if their configuration or logs differ.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. pgAudit records audit events in PostgreSQL server logs, not in a queryable pgAudit table.
       Retrieve actual events from the configured log destination, such as CloudWatch Logs, syslog, csvlog, or jsonlog.
*/
WITH capability AS (
    SELECT
        EXISTS (
            SELECT 1 FROM pg_available_extensions WHERE name = 'pgaudit'
        ) AS package_available,
        EXISTS (
            SELECT 1 FROM pg_extension WHERE extname = 'pgaudit'
        ) AS extension_installed,
        'pgaudit' = ANY (
            string_to_array(
                replace(current_setting('shared_preload_libraries', true), ' ', ''),
                ','
            )
        ) AS library_preloaded
),
wanted_settings(name, purpose) AS (
    VALUES
        ('pgaudit.log', 'Audit classes enabled: READ, WRITE, FUNCTION, ROLE, DDL, MISC, MISC_SET, ALL.'),
        ('pgaudit.log_catalog', 'Whether catalog relations are logged for relevant statements.'),
        ('pgaudit.log_client', 'Whether audit messages are also visible to clients; normally off in production.'),
        ('pgaudit.log_level', 'Server log severity used for audit entries.'),
        ('pgaudit.log_parameter', 'Whether statement parameters are included; review sensitive-data exposure.'),
        ('pgaudit.log_parameter_max_size', 'Maximum parameter size included in audit logging.'),
        ('pgaudit.log_relation', 'Whether separate audit entries are emitted per referenced relation.'),
        ('pgaudit.log_rows', 'Whether affected-row counts are logged.'),
        ('pgaudit.log_statement_once', 'Whether statement text and parameters are logged only once per statement.'),
        ('pgaudit.role', 'Master audit role for object-level audit logging.')
),
configuration AS (
    SELECT
        w.name,
        s.setting,
        s.source,
        s.pending_restart,
        w.purpose
    FROM wanted_settings w
    LEFT JOIN pg_settings s ON s.name = w.name
)
SELECT
    current_database() AS database_name,
    c.package_available,
    c.extension_installed,
    c.library_preloaded,
    CASE
        WHEN NOT c.package_available THEN 'PACKAGE_NOT_AVAILABLE'
        WHEN NOT c.library_preloaded THEN 'PRELOAD_AND_RESTART_REQUIRED'
        WHEN NOT c.extension_installed THEN 'CREATE_EXTENSION_REQUIRED'
        ELSE 'PGAUDIT_READY'
    END AS overall_status,
    cfg.name AS setting_name,
    coalesce(cfg.setting, '<not registered>') AS setting_value,
    coalesce(cfg.source, '<not registered>') AS setting_source,
    coalesce(cfg.pending_restart, false) AS pending_restart,
    cfg.purpose,
    CASE
        WHEN NOT c.package_available THEN 'Install/enable pgAudit using the server or managed-service procedure.'
        WHEN NOT c.library_preloaded THEN 'Add pgaudit to shared_preload_libraries and restart using the approved change process.'
        WHEN NOT c.extension_installed THEN 'CREATE EXTENSION IF NOT EXISTS pgaudit;'
        WHEN cfg.name = 'pgaudit.log' AND coalesce(cfg.setting, 'none') = 'none' THEN 'Set an approved audit class policy; none produces no session audit records.'
        ELSE 'Review against the security audit policy and inspect the external PostgreSQL log destination.'
    END AS action
FROM capability c
CROSS JOIN configuration cfg
ORDER BY cfg.name;

-- SAMPLE_OUTPUT_BEGIN
-- database_name | package_available | extension_installed | library_preloaded | overall_status
-- applicationdb | t                 | t                   | t                 | PGAUDIT_READY
-- SAMPLE_OUTPUT_END
