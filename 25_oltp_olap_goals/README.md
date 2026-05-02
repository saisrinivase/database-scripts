# 25_oltp_olap_goals

Workload classification and OLTP/OLAP pressure indicators.

Scripts in this area: `4`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @25_oltp_olap_goals/<script>.sql`.

## Scripts

- `01_workload_signature_oltp_vs_olap.sql`
- `02_oltp_latency_goal_candidates.sql`
- `03_olap_throughput_candidates.sql`
- `04_mixed_workload_pressure.sql`
