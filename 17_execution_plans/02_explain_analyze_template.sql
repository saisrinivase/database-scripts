/*
Purpose: Template to read and understand execution plans for problematic queries.
Area: Execution Plans
Usage: Replace `SELECT 1` with target SQL and run in a lower environment first.
*/
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, WAL, SETTINGS, FORMAT TEXT)
SELECT 1;
