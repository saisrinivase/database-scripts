# 35_pooler_proxy_diagnostics

Connection saturation, session distribution, cursor cache, shared server, and proxy/client signals.

Scripts in this area: `5`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @35_pooler_proxy_diagnostics/<script>.sql`.

## Scripts

- `01_connection_saturation_queue_risk.sql`
- `02_connection_distribution_by_app_user.sql`
- `03_session_cursor_cache_risk.sql`
- `04_shared_server_pooling_risk.sql`
- `05_pooler_proxy_inventory_signals.sql`
