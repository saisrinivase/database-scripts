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
