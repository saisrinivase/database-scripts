# 31_logging_error_signatures

Error log, slow query digests, waits, locks, and deadlock indicators.

Scripts in this area: `4`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 31_logging_error_signatures/<script>.sql`.

## Scripts

- `01_logging_configuration_sanity.sql`
- `02_error_signature_indicators.sql`
- `03_slow_query_digest_correlation.sql`
- `04_lock_wait_deadlock_signatures.sql`
