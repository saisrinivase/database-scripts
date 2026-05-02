# 10_maintenance_monitoring

DB writer, cache, checkpoint, top SQL, parameter drift, and capacity monitoring.

Scripts in this area: `5`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @10_maintenance_monitoring/<script>.sql`.

## Scripts

- `01_db_writer_checkpoint_stats.sql`
- `02_cache_hit_ratio.sql`
- `03_top_sql_by_resource.sql`
- `04_non_default_config.sql`
- `05_connection_capacity.sql`
