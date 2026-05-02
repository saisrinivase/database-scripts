# 16_internals_deep_dive

Transactions, table files, dictionary size, dependencies, LOB storage, and purge profile.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 16_internals_deep_dive/<script>.sql`.

## Scripts

- `01_transaction_history_age.sql`
- `02_table_file_mapping.sql`
- `03_system_catalog_size_profile.sql`
- `04_dependency_fanout_objects.sql`
- `05_innodb_lob_storage_breakdown.sql`
- `06_mvcc_purge_profile.sql`
