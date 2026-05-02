# 01_database_size

Database, tablespace, datafile, temp file, and segment size diagnostics.

Scripts in this area: `11`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @01_database_size/<script>.sql`.

## Scripts

- `01_databases_size.sql`
- `02_current_database_size_breakdown.sql`
- `03_tablespaces_size.sql`
- `04_tablespace_growth_awr_daily.sql`
- `05_tablespace_growth_forecast_awr.sql`
- `06_datafile_autoextend_headroom.sql`
- `07_database_growth_awr_daily.sql`
- `08_top_segments_by_size.sql`
- `09_top_segment_growth_awr.sql`
- `10_temp_undo_space_usage.sql`
- `11_pdb_storage_usage.sql`
