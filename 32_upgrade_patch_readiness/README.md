# 32_upgrade_patch_readiness

Version, component, SQL patch, invalid object, NLS, and post-upgrade regression checks.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @32_upgrade_patch_readiness/<script>.sql`.

## Scripts

- `01_version_upgrade_path_overview.sql`
- `02_component_patch_dependencies.sql`
- `03_preupgrade_invalid_objects_gate.sql`
- `04_nls_collation_mismatch_risk.sql`
- `05_postupgrade_sql_regression_watchlist.sql`
- `06_parameter_deprecated_settings.sql`
