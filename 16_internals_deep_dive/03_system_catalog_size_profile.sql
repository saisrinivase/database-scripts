/*
PostgreSQL DBA Script: System Catalog Size Profile
Purpose: Profile largest system catalogs to understand metadata footprint.
Area: Internals Deep Dive
Usage: Run in each critical database.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS catalog_name,
    c.relkind,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname IN ('pg_catalog', 'information_schema')
ORDER BY total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--     schema_name     |                  catalog_name                  | relkind | total_bytes | total_pretty 
-- --------------------+------------------------------------------------+---------+-------------+--------------
--  pg_catalog         | pg_proc                                        | r       |     1302528 | 1272 kB
--  pg_catalog         | pg_attribute                                   | r       |     1089536 | 1064 kB
--  pg_catalog         | pg_rewrite                                     | r       |      778240 | 760 kB
--  pg_catalog         | pg_description                                 | r       |      638976 | 624 kB
--  pg_catalog         | pg_statistic                                   | r       |      606208 | 592 kB
--  pg_catalog         | pg_depend                                      | r       |      450560 | 440 kB
--  pg_catalog         | pg_collation                                   | r       |      360448 | 352 kB
--  pg_catalog         | pg_class                                       | r       |      319488 | 312 kB
--  pg_catalog         | pg_constraint                                  | r       |      311296 | 304 kB
--  pg_catalog         | pg_type                                        | r       |      294912 | 288 kB
--  pg_catalog         | pg_proc_proname_args_nsp_index                 | i       |      270336 | 264 kB
--  pg_catalog         | pg_attribute_relid_attnam_index                | i       |      245760 | 240 kB
--  pg_catalog         | pg_operator                                    | r       |      237568 | 232 kB
--  pg_catalog         | pg_amop                                        | r       |      229376 | 224 kB
--  pg_catalog         | pg_description_o_c_o_index                     | i       |      221184 | 216 kB
--  pg_catalog         | pg_amproc                                      | r       |      147456 | 144 kB
--  pg_catalog         | pg_attribute_relid_attnum_index                | i       |      147456 | 144 kB
--  pg_catalog         | pg_depend_depender_index                       | i       |      139264 | 136 kB
--  pg_catalog         | pg_index                                       | r       |      131072 | 128 kB
--  pg_catalog         | pg_depend_reference_index                      | i       |      114688 | 112 kB
--  pg_catalog         | pg_ts_config_map                               | r       |      106496 | 104 kB
--  information_schema | sql_features                                   | r       |      106496 | 104 kB
--  pg_catalog         | pg_auth_members                                | r       |      106496 | 104 kB
--  pg_catalog         | pg_conversion                                  | r       |       98304 | 96 kB
--  pg_catalog         | pg_proc_oid_index                              | i       |       98304 | 96 kB
--  pg_catalog         | pg_opclass                                     | r       |       90112 | 88 kB
--  pg_catalog         | pg_opfamily                                    | r       |       81920 | 80 kB
--  pg_catalog         | pg_namespace                                   | r       |       81920 | 80 kB
--  pg_catalog         | pg_cast                                        | r       |       81920 | 80 kB
--  pg_catalog         | pg_extension                                   | r       |       81920 | 80 kB
--  pg_catalog         | pg_database                                    | r       |       81920 | 80 kB
--  pg_catalog         | pg_init_privs                                  | r       |       81920 | 80 kB
--  pg_catalog         | pg_aggregate                                   | r       |       81920 | 80 kB
--  pg_catalog         | pg_language                                    | r       |       81920 | 80 kB
--  pg_catalog         | pg_collation_name_enc_nsp_index                | i       |       81920 | 80 kB
--  pg_catalog         | pg_ts_dict                                     | r       |       81920 | 80 kB
--  pg_catalog         | pg_tablespace                                  | r       |       81920 | 80 kB
--  pg_catalog         | pg_range                                       | r       |       73728 | 72 kB
--  pg_catalog         | pg_authid                                      | r       |       73728 | 72 kB
--  pg_catalog         | pg_am                                          | r       |       73728 | 72 kB
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
