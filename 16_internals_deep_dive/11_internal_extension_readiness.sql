/*
PostgreSQL DBA Script: Internal Extension Readiness
Purpose: Show whether key inspection extensions are installed/available and what diagnostic area each unlocks.
Area: Internals Deep Dive
Usage: Run before deep internals troubleshooting to know whether pageinspect, pgstattuple, pg_visibility, pg_buffercache, amcheck, and pg_stat_statements are ready.
Sample Output: Columns include extension_name, installed_version, default_version, readiness, unlocks_diagnostics, install_command.
Notes: Read-only diagnostic. Does not install extensions.
*/
WITH wanted AS (
    SELECT *
    FROM (VALUES
        ('pageinspect', 'Inspect heap/index pages, btree metadata, line pointers, visibility bits, and low-level corruption evidence.'),
        ('pgstattuple', 'Estimate live/dead/free space and bloat using tuple-level sampling/functions.'),
        ('pg_visibility', 'Inspect visibility map and all-visible/all-frozen coverage.'),
        ('pg_buffercache', 'Inspect shared buffer residency and hot relation/index blocks.'),
        ('amcheck', 'Check btree/index consistency and corruption evidence.'),
        ('pg_stat_statements', 'Attribute SQL runtime, IO, temp spills, WAL, and planning cost.'),
        ('auto_explain', 'Capture slow plans from production sessions through server logging.'),
        ('hypopg', 'Test hypothetical indexes before creating real indexes.')
    ) AS w(extension_name, unlocks_diagnostics)
)
SELECT
    w.extension_name,
    e.installed_version,
    e.default_version,
    CASE
        WHEN e.installed_version IS NOT NULL THEN 'INSTALLED'
        WHEN e.name IS NOT NULL THEN 'AVAILABLE_NOT_INSTALLED'
        ELSE 'NOT_AVAILABLE_ON_SERVER'
    END AS readiness,
    w.unlocks_diagnostics,
    CASE
        WHEN e.installed_version IS NOT NULL THEN 'Already installed in current database.'
        WHEN e.name IS NOT NULL THEN format('CREATE EXTENSION IF NOT EXISTS %I;', w.extension_name)
        ELSE 'Install extension package or managed-service equivalent before using related deep-dive scripts.'
    END AS install_command_or_guidance,
    CASE
        WHEN w.extension_name = 'pg_stat_statements' AND e.installed_version IS NULL THEN 'High priority for pro SQL diagnosis.'
        WHEN w.extension_name IN ('amcheck', 'pg_visibility', 'pageinspect') AND e.installed_version IS NULL THEN 'Useful for corruption, visibility, and page-level internals.'
        WHEN w.extension_name = 'pg_buffercache' AND e.installed_version IS NULL THEN 'Useful for buffer residency, but snapshot interpretation needs care.'
        ELSE 'Ready or optional depending on incident type.'
    END AS priority_hint
FROM wanted w
LEFT JOIN pg_available_extensions e
  ON e.name = w.extension_name
ORDER BY
    CASE
        WHEN w.extension_name = 'pg_stat_statements' THEN 1
        WHEN w.extension_name IN ('amcheck', 'pg_visibility', 'pageinspect', 'pgstattuple') THEN 2
        ELSE 3
    END,
    w.extension_name;

-- SAMPLE_OUTPUT_BEGIN
-- extension_name     | installed_version | readiness               | install_command_or_guidance
-- pg_stat_statements | 1.10              | INSTALLED               | Already installed in current database.
-- pageinspect        |                   | AVAILABLE_NOT_INSTALLED | CREATE EXTENSION IF NOT EXISTS pageinspect;
-- SAMPLE_OUTPUT_END
