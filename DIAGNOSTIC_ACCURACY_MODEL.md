# PostgreSQL Diagnostic Accuracy Model

This repository separates facts, measurements, proxies, and recommendations. A script passing execution tests proves compatibility; it does not make every diagnosis a certainty.

## Evidence classes

| Class | Typical evidence | Engineering confidence when prerequisites are met |
|---|---|---:|
| Direct catalog fact | settings, object definitions, sizes, privileges | 95-99% |
| Point-in-time state | sessions, locks, waits, replication, progress | 90-98% for the capture instant |
| Cumulative counter | pg_stat_* and pg_stat_statements since reset | 85-95% with a known observation window |
| Interval rate | two snapshots with reset detection and elapsed time | 90-98% |
| Heuristic candidate | bloat estimate, missing-index candidate, tuning threshold | 65-85% |
| SQL-only CPU or memory attribution | elapsed/block/temp proxies | 50-75% |
| Correlated root cause | SQL plus EXPLAIN, waits, host/AWS metrics, and workload context | 80-95% |

These are engineering confidence ranges, not statistical guarantees. Permissions, counter resets, sampling gaps, workload changes, managed-service visibility, and disabled instrumentation can reduce confidence.

## Non-negotiable interpretation rules

- `pg_stat_statements.total_exec_time` is elapsed executor time, not CPU time.
- Elapsed time minus measured block I/O time is a non-I/O elapsed-time proxy, not measured CPU. It is unavailable when `track_io_timing` is off.
- `temp_blks_read` and `temp_blks_written` measure temporary-file I/O. They identify spill pressure but do not measure allocated RAM.
- Shared-block hits are logical accesses, not proof that every access came from PostgreSQL shared buffers rather than the operating-system cache.
- Cumulative percentages describe the period since statistics reset. They do not describe a requested wall-clock interval unless snapshots bound that interval.
- A recommendation is an investigation priority. Apply a change only after validating the plan, workload, resource metrics, and operational risk.

## Validation standard

The CI workflow runs every eligible SQL script on PostgreSQL 15, 16, 17, and 18. It enforces pgAdmin compatibility, required purpose/usage/notes/sample-output documentation, stateful workflow isolation, and semantic naming rules for high-risk CPU and memory claims.

Three deliberately heavy demonstration scripts are excluded from routine CI because they generate large data sets. Their exclusion is explicit in the harness and must not be presented as a passing runtime result.

## Using the scripts like an SME

1. Establish the statistics reset time and observation window.
2. Start with direct live state and interval counters.
3. Treat rankings as prioritization, not root-cause proof.
4. Correlate query candidates with `EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS)`, wait events, host or AWS metrics, and application timing.
5. Re-measure the same interval after a controlled change.
