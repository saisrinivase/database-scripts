# 08_replication_ha

Data Guard, archivelog, redo generation, standby apply, and high availability posture.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @08_replication_ha/<script>.sql`.

## Scripts

- `01_primary_replication_status.sql`
- `02_standby_replay_status.sql`
- `03_replication_slots_health.sql`
- `04_redo_generation_rate.sql`
