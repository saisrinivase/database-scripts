# Problem Identification and PostgreSQL Internals

Purpose: Start from an observed symptom, identify the responsible PostgreSQL subsystem, and collect evidence before recommending a change.

## Run Order

1. `01_symptom_to_subsystem_router.sql`
2. Run the focused script selected by the symptom row.
3. Compare SQL evidence with the incident time window, PostgreSQL logs, host/cloud telemetry, and application behavior.

## Focused Diagnostics

- `02_lock_manager_full_diagnosis.sql`: heavyweight, advisory, predicate, transaction, and fast-path locks.
- `03_logical_replication_cdc_health.sql`: publications, subscriptions, workers, logical slots, synchronization, and replica identity.
- `04_partition_pruning_maintenance_health.sql`: pruning, leaf balance, default partitions, partition indexes, and pg_partman readiness.
- `05_extension_runtime_health.sql`: pg_cron, TimescaleDB, Citus, and pgvector capability and runtime signals.
- `06_pg18_async_io_readiness.sql`: PostgreSQL 18 asynchronous-I/O configuration and PostgreSQL 16+ pg_stat_io evidence.
- `07_row_level_security_policy_health.sql`: RLS enable/force state, policies, role scope, owners, and BYPASSRLS.

## Coverage Reference

The topic taxonomy was compared with the PostgreSQL In-Depth curriculum at:

`https://academy.jatinjainsaraf.com/postgresql-in-depth`

The repository remains a diagnostic toolkit, not a copy of the course. Beginner SQL and application-design lessons are routed to existing design, query, security, indexing, and application folders. New SQL was added only where an operational subsystem lacked direct problem-identification evidence.
