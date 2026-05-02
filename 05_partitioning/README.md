# 05_partitioning

Partition inventory, partition sizing, partition index posture, and candidates.

Scripts in this area: `7`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 05_partitioning/<script>.sql`.

## Scripts

- `01_partitioned_tables_overview.sql`
- `02_partition_size_distribution.sql`
- `03_partitions_without_indexes.sql`
- `04_partitioning_recommendation_candidates.sql`
- `05_partition_sme_decision_scorecard.sql`
- `06_partition_target_table_deep_advisor.sql`
- `07_partition_lab_generate_5gb_timeseries.sql`
