# 14_connection_workload

Connection distribution, idle sessions, thread states, limits, and XA state.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 14_connection_workload/<script>.sql`.

## Scripts

- `01_connections_by_user_app_db.sql`
- `02_idle_in_transaction_risk.sql`
- `03_connection_state_distribution.sql`
- `04_role_connection_limit_risk.sql`
- `05_backend_type_distribution.sql`
- `06_prepared_xa_transactions_status.sql`
