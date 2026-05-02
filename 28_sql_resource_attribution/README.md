# 28_sql_resource_attribution

SQL resource attribution by SQL ID, service, parsing schema, and infrastructure tier.

Scripts in this area: `8`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @28_sql_resource_attribution/<script>.sql`.

## Scripts

- `01_sql_query_resource_percent.sql`
- `02_sql_resource_percent_by_service.sql`
- `03_sql_resource_percent_by_schema.sql`
- `04_sql_infra_tier_classification.sql`
- `05_ash_resource_by_service_module.sql`
- `06_awr_sql_resource_by_schema.sql`
- `07_current_resource_by_service.sql`
- `08_top_objects_by_ash_wait.sql`
