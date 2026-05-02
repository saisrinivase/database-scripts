# 34_consistency_integrity_checks

Invalid metadata, CHECK TABLE command generation, corruption indicators, and MVCC risks.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 34_consistency_integrity_checks/<script>.sql`.

## Scripts

- `01_invalid_indexes_and_constraints.sql`
- `02_checksum_status_and_failures.sql`
- `03_lob_dictionary_consistency_signals.sql`
- `04_check_table_candidate_commands.sql`
- `05_mvcc_visibility_integrity_risk.sql`
