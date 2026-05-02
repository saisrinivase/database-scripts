# 19_dml_optimization

Write-heavy tables, row movement, index support for foreign keys, and DML pressure.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @19_dml_optimization/<script>.sql`.

## Scripts

- `01_write_heavy_tables.sql`
- `02_hot_update_efficiency.sql`
- `03_missing_fk_supporting_indexes.sql`
- `04_dml_bloat_pressure.sql`
