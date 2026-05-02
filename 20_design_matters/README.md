# 20_design_matters

Schema design anti-patterns such as missing primary keys, wide tables, and high-null columns.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @20_design_matters/<script>.sql`.

## Scripts

- `01_tables_without_primary_keys.sql`
- `02_wide_tables_profile.sql`
- `03_overindexed_tables.sql`
- `04_high_nullability_columns.sql`
