# 14_connection_workload

Session distribution, idle sessions, connection capacity, and distributed transaction status.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @14_connection_workload/<script>.sql`.

## Scripts

- `01_connections_by_user_app_db.sql`
- `02_idle_in_transaction_risk.sql`
- `03_connection_state_distribution.sql`
- `04_role_connection_limit_risk.sql`
- `05_backend_type_distribution.sql`
- `06_distributed_transactions_status.sql`
