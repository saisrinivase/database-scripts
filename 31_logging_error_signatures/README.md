# Logging and Error Signature Diagnostics

Purpose: SQL-first triage for logging configuration quality and recurring error symptom patterns.

## Run Order

1. `01_logging_configuration_sanity.sql`
2. `02_error_signature_indicators.sql`
3. `03_slow_query_log_vs_pgss_correlation.sql`
4. `04_lock_wait_deadlock_signatures.sql`

## Notes

- Database views cannot replace full log parsing; they provide fast triage signals to narrow investigation.
- Combine this area with log files or centralized observability for full incident timelines.
