# 10_maintenance_monitoring

InnoDB checkpoint, cache hit, top statements, variable drift, and connection capacity.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 10_maintenance_monitoring/<script>.sql`.

## Scripts

- `01_innodb_checkpoint_stats.sql`
- `02_cache_hit_ratio.sql`
- `03_top_statements_performance_schema.sql`
- `04_non_default_config.sql`
- `05_connection_capacity.sql`
