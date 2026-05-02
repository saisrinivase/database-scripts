# 35_pooler_proxy_diagnostics

Connection saturation, proxy patterns, prepared statement cache, and pooling risks.

Scripts in this area: `5`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 35_pooler_proxy_diagnostics/<script>.sql`.

## Scripts

- `01_connection_saturation_queue_risk.sql`
- `02_connection_distribution_by_app_user.sql`
- `03_prepared_statement_cache_risk.sql`
- `04_proxy_transaction_pooling_risk.sql`
- `05_pooler_proxy_inventory_signals.sql`
