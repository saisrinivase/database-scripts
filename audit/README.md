# Production-readiness audit harness

This directory contains independent audit evidence. It does not treat successful
execution as proof of production safety.

`validate_readonly.sh` executes every SQL file in its own read-only transaction
with a statement timeout, lock timeout, idle-transaction timeout, and temporary
file limit. Persistent setup, capture, lab, and mutation scripts are expected to
fail this gate and must be validated separately in an isolated disposable
database.

The production review adds two further gates:

1. Static semantic review: privileges, locks, persistent mutations, catalog
   complexity, relation scans, size-function calls, sleeps, and version/provider
   dependencies.
2. Scale classification: bounded catalog query, workload-counter query,
   relation-proportional query, cluster-wide relation loop, interval sampler, or
   intentionally destructive lab/setup workflow.

No script should be labeled safe for a 10 TB or 50 TB production system solely
because it succeeds on a small test database.

`build_cross_database_readonly.py` generates a bounded psql master file for all
reader-safe scripts. `cross-database-certification.tsv` and
`CROSS_DATABASE_CERTIFICATION.md` record multi-database and controlled-workload
evidence. The script matrix separates runtime compatibility from evidence type,
interpretation limitations, and scenario validation.

Example:

```bash
python3 audit/build_cross_database_readonly.py appdb /tmp/appdb-readonly.sql
psql -X -d postgres -f /tmp/appdb-readonly.sql > /tmp/appdb-readonly.log 2>&1
python3 audit/parse_cross_database_log.py appdb /tmp/appdb-readonly.log /tmp/appdb-readonly.tsv
```

The parser evaluates every error between script markers. It does not trust only
the last command status because a multi-statement script can encounter an early
error and later finish with a successful statement.
