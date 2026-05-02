# 13_io_redo_checkpoints

File I/O, table/index I/O, binary log, redo, checkpoint, and temporary table pressure.

Scripts in this area: `7`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 13_io_redo_checkpoints/<script>.sql`.

## Scripts

- `01_database_io_profile.sql`
- `02_table_io_hotspots.sql`
- `03_index_io_hotspots.sql`
- `04_binlog_replication_health.sql`
- `05_checkpoint_pressure_indicators.sql`
- `06_temp_file_usage_by_database.sql`
- `07_mysql_io_overview.sql`
