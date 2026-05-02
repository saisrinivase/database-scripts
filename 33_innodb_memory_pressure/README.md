# 33_innodb_memory_pressure

InnoDB checkpoint, redo, purge, parallelism, buffer pool, and temp pressure.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 33_innodb_memory_pressure/<script>.sql`.

## Scripts

- `01_innodb_checkpoint_pressure.sql`
- `02_redo_binlog_writer_pressure.sql`
- `03_purge_stats_worker_pressure.sql`
- `04_parallel_worker_pressure.sql`
- `05_temp_spill_work_mem_pressure.sql`
