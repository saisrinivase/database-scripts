# Pooler and Proxy Diagnostics

Purpose: Troubleshoot connection pool/proxy behavior (PgBouncer/PgPool/RDS Proxy style) from PostgreSQL-side evidence.

## Run Order

1. `01_connection_saturation_queue_risk.sql`
2. `02_connection_distribution_by_app_user.sql`
3. `03_prepared_statement_pooling_risk.sql`
4. `04_tx_pooling_incompatible_patterns_pgss.sql`
5. `05_pooler_proxy_inventory_signals.sql`

## Notes

- Pool queue depth often lives in the pooler layer; these scripts provide database-side indicators.
- Pair this area with pooler admin metrics for complete diagnosis.
