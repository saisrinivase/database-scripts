# Background Processes and Memory Pressure

Purpose: Focused triage for CPU/IO pressure outside direct query text, including checkpointer/bgwriter, WAL writer, autovacuum, parallel workers, and spill storms.

## Run Order

1. `01_bgwriter_checkpointer_pressure.sql`
2. `02_wal_writer_archiver_pressure.sql`
3. `03_autovacuum_worker_pressure.sql`
4. `04_parallel_worker_pressure.sql`
5. `05_temp_spill_work_mem_pressure.sql`

## Notes

- This area complements `28_pgss_resource_attribution` by diagnosing non-query background pressure.
- Use snapshots over time to validate trend direction.
