# 34_consistency_integrity_checks

Invalid objects, corruption views, LOB dictionary signals, and validate-structure commands.

Scripts in this area: `5`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @34_consistency_integrity_checks/<script>.sql`.

## Scripts

- `01_invalid_indexes_and_constraints.sql`
- `02_checksum_status_and_failures.sql`
- `03_lob_dictionary_consistency_signals.sql`
- `04_validate_structure_candidate_commands.sql`
- `05_undo_visibility_integrity_risk.sql`
