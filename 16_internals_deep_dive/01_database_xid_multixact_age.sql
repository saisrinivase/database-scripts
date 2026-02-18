/*
Purpose: Show XID and multixact age by database to assess wraparound risk.
Area: Internals Deep Dive
Usage: Monitor regularly on high-write systems.
*/
SELECT
    datname AS database_name,
    age(datfrozenxid) AS xid_age,
    mxid_age(datminmxid) AS multixact_age,
    datconnlimit,
    datallowconn
FROM pg_database
ORDER BY xid_age DESC, multixact_age DESC;
