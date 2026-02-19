/*
Purpose: Create an unpartitioned lab table with 5GB+ time-series data (5/10-year span) to test partition decisions.
Area: Partitioning
Usage:
  psql -d <db> \
    -v lab_schema='partition_lab' \
    -v lab_table='fact_events_10y_unpartitioned' \
    -v history_years='10' \
    -v target_gb='5' \
    -v payload_bytes='1024' \
    -v batch_rows='250000' \
    -f 05_partitioning/07_partition_lab_generate_5gb_timeseries.sql
*/
\set ON_ERROR_STOP on

\if :{?lab_schema}
\else
\set lab_schema 'partition_lab'
\endif

\if :{?lab_table}
\else
\set lab_table 'fact_events_10y_unpartitioned'
\endif

\if :{?history_years}
\else
\set history_years '10'
\endif

\if :{?target_gb}
\else
\set target_gb '5'
\endif

\if :{?payload_bytes}
\else
\set payload_bytes '1024'
\endif

\if :{?batch_rows}
\else
\set batch_rows '250000'
\endif

DROP TABLE IF EXISTS pg_temp.partition_lab_params;
CREATE TEMP TABLE pg_temp.partition_lab_params AS
SELECT
    :'lab_schema'::text AS lab_schema,
    :'lab_table'::text AS lab_table,
    :'history_years'::int AS history_years,
    :'target_gb'::numeric AS target_gb,
    :'payload_bytes'::int AS payload_bytes,
    :'batch_rows'::int AS batch_rows;

DO $$
DECLARE
    v_schema text;
    v_table text;
    v_history_years int;
    v_target_gb numeric;
    v_payload_bytes int;
    v_batch_rows int;
    v_target_bytes bigint;
    v_start_date date;
    v_end_date date := current_date;
    v_day_count int;
    v_seed bigint := 1;
    v_current_size bigint := 0;
    v_payload_repeat int;
    v_fq_name text;
BEGIN
    SELECT
        lab_schema,
        lab_table,
        history_years,
        target_gb,
        payload_bytes,
        batch_rows
    INTO
        v_schema,
        v_table,
        v_history_years,
        v_target_gb,
        v_payload_bytes,
        v_batch_rows
    FROM pg_temp.partition_lab_params;

    IF v_history_years < 1 THEN
        RAISE EXCEPTION 'history_years must be >= 1';
    END IF;
    IF v_target_gb < 1 THEN
        RAISE EXCEPTION 'target_gb must be >= 1';
    END IF;
    IF v_payload_bytes < 128 THEN
        RAISE EXCEPTION 'payload_bytes must be >= 128';
    END IF;
    IF v_batch_rows < 50000 THEN
        RAISE EXCEPTION 'batch_rows should be >= 50000 for practical load speed';
    END IF;

    v_target_bytes := (v_target_gb * 1024 * 1024 * 1024)::bigint;
    v_start_date := (current_date - make_interval(years => v_history_years))::date;
    v_day_count := greatest((v_end_date - v_start_date) + 1, 1);
    v_payload_repeat := ceil(v_payload_bytes / 32.0)::int;
    v_fq_name := format('%I.%I', v_schema, v_table);

    EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', v_schema);
    EXECUTE format('DROP TABLE IF EXISTS %I.%I', v_schema, v_table);
    EXECUTE format(
        'CREATE UNLOGGED TABLE %I.%I (
            event_id bigserial PRIMARY KEY,
            event_date date NOT NULL,
            account_id bigint NOT NULL,
            amount numeric(14,2) NOT NULL,
            payload text NOT NULL,
            created_at timestamptz NOT NULL DEFAULT now()
        )',
        v_schema,
        v_table
    );
    EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN payload SET STORAGE EXTERNAL', v_schema, v_table);

    LOOP
        EXECUTE format(
            $fmt$
            INSERT INTO %I.%I (event_date, account_id, amount, payload)
            SELECT
                (%L::date + ((gs - 1) %% %s))::date AS event_date,
                (100000 + (gs %% 500000))::bigint AS account_id,
                round((10 + random() * 990)::numeric, 2) AS amount,
                left(repeat(md5(gs::text || random()::text), %s), %s) AS payload
            FROM generate_series(%s, %s) AS gs
            $fmt$,
            v_schema,
            v_table,
            v_start_date,
            v_day_count,
            v_payload_repeat,
            v_payload_bytes,
            v_seed,
            v_seed + v_batch_rows - 1
        );

        v_seed := v_seed + v_batch_rows;

        EXECUTE format('SELECT pg_total_relation_size(%L::regclass)', v_fq_name)
        INTO v_current_size;

        RAISE NOTICE 'Current size: % GB (target=% GB, rows_seed=%)',
            round(v_current_size / 1024.0 / 1024.0 / 1024.0, 2),
            v_target_gb,
            v_seed;

        EXIT WHEN v_current_size >= v_target_bytes;
        EXIT WHEN v_seed > 200000000;
    END LOOP;

    EXECUTE format('ANALYZE %I.%I', v_schema, v_table);

    EXECUTE format(
        $fmt$
        CREATE TEMP TABLE pg_temp.partition_lab_result AS
        SELECT
            %L::text AS schema_name,
            %L::text AS table_name,
            %s::numeric AS target_size_gb,
            round(pg_total_relation_size(%L::regclass) / 1024.0 / 1024.0 / 1024.0, 2) AS actual_size_gb,
            min(event_date) AS min_event_date,
            max(event_date) AS max_event_date,
            round(extract(epoch FROM (max(event_date)::timestamp - min(event_date)::timestamp)) / 31557600.0, 2) AS span_years,
            count(*)::bigint AS row_count,
            pg_size_pretty(pg_total_relation_size(%L::regclass)) AS table_size_pretty
        FROM %I.%I
        $fmt$,
        v_schema,
        v_table,
        v_target_gb,
        v_fq_name,
        v_fq_name,
        v_schema,
        v_table
    );
END;
$$;

SELECT
    schema_name,
    table_name,
    target_size_gb,
    actual_size_gb,
    table_size_pretty,
    min_event_date,
    max_event_date,
    span_years,
    row_count,
    CASE
        WHEN actual_size_gb >= 5 AND span_years >= 10 THEN 'Excellent lab candidate for RANGE partitioning by event_date.'
        WHEN actual_size_gb >= 5 AND span_years >= 5 THEN 'Strong lab candidate for monthly partitioning tests.'
        WHEN actual_size_gb >= 5 THEN 'Size target met; increase history_years for long-range pruning tests.'
        ELSE 'Increase target_gb or rerun to hit 5GB threshold.'
    END AS partition_test_readiness,
    'Run 05_partitioning/06_partition_target_table_deep_advisor.sql with target_schema='''
    || schema_name
    || ''', target_table='''
    || table_name
    || ''', target_time_column=''event_date''.' AS next_step
FROM pg_temp.partition_lab_result;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture file: /tmp/partition_new_outputs_20260218/07.out.txt
--
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:46: NOTICE:  schema "pg_temp" does not exist, skipping
-- DROP TABLE
-- SELECT 1
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  table "fact_events_10y_unpartitioned" does not exist, skipping
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 0.28 GB (target=5 GB, rows_seed=250001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 0.56 GB (target=5 GB, rows_seed=500001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 0.83 GB (target=5 GB, rows_seed=750001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 1.11 GB (target=5 GB, rows_seed=1000001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 1.39 GB (target=5 GB, rows_seed=1250001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 1.67 GB (target=5 GB, rows_seed=1500001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 1.94 GB (target=5 GB, rows_seed=1750001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 2.22 GB (target=5 GB, rows_seed=2000001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 2.50 GB (target=5 GB, rows_seed=2250001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 2.78 GB (target=5 GB, rows_seed=2500001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 3.06 GB (target=5 GB, rows_seed=2750001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 3.33 GB (target=5 GB, rows_seed=3000001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 3.61 GB (target=5 GB, rows_seed=3250001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 3.89 GB (target=5 GB, rows_seed=3500001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 4.17 GB (target=5 GB, rows_seed=3750001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 4.44 GB (target=5 GB, rows_seed=4000001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 4.72 GB (target=5 GB, rows_seed=4250001)
-- psql:/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/05_partitioning/07_partition_lab_generate_5gb_timeseries.sql:185: NOTICE:  Current size: 5.00 GB (target=5 GB, rows_seed=4500001)
-- DO
--   schema_name  |          table_name           | target_size_gb | actual_size_gb | table_size_pretty | min_event_date | max_event_date | span_years | row_count |                   partition_test_readiness                    |                                                                                     next_step                                                                                     
-- ---------------+-------------------------------+----------------+----------------+-------------------+----------------+----------------+------------+-----------+---------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  partition_lab | fact_events_10y_unpartitioned |              5 |           5.00 | 5120 MB           | 2016-02-18     | 2026-02-18     |      10.00 |   4500000 | Excellent lab candidate for RANGE partitioning by event_date. | Run 05_partitioning/06_partition_target_table_deep_advisor.sql with target_schema='partition_lab', target_table='fact_events_10y_unpartitioned', target_time_column='event_date'.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
