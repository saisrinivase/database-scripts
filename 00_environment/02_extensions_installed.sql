/*
Purpose: List installed extensions and their schema/version.
Area: Environment / Internals
Usage: Run in any database.
*/
SELECT
    e.extname AS extension_name,
    e.extversion AS extension_version,
    n.nspname AS extension_schema,
    pg_get_userbyid(e.extowner) AS extension_owner
FROM pg_extension e
JOIN pg_namespace n
    ON n.oid = e.extnamespace
ORDER BY e.extname;
