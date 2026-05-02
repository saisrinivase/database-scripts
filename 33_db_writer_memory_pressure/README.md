# 33_db_writer_memory_pressure

DB writer, checkpoint, redo writer, stats jobs, parallel workers, SGA/PGA, and temp spill pressure.

Scripts in this area: `5`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @33_db_writer_memory_pressure/<script>.sql`.

## Scripts

- `01_db_writer_checkpointer_pressure.sql`
- `02_redo_writer_archiver_pressure.sql`
- `03_stats_gathering_job_pressure.sql`
- `04_parallel_worker_pressure.sql`
- `05_temp_spill_work_mem_pressure.sql`
