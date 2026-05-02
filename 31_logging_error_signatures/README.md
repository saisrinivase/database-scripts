# 31_logging_error_signatures

ADR, alert log, trace, error signatures, slow SQL, lock waits, and deadlock indicators.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @31_logging_error_signatures/<script>.sql`.

## Scripts

- `01_logging_configuration_sanity.sql`
- `02_error_signature_indicators.sql`
- `03_slow_sql_trace_correlation.sql`
- `04_lock_wait_deadlock_signatures.sql`
