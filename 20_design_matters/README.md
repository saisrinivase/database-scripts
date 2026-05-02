# 20_design_matters

Schema design risks such as missing primary keys, wide tables, over-indexing, and nullable-heavy tables.

Scripts in this area: `4`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 20_design_matters/<script>.sql`.

## Scripts

- `01_tables_without_primary_keys.sql`
- `02_wide_tables_profile.sql`
- `03_overindexed_tables.sql`
- `04_high_nullability_columns.sql`
