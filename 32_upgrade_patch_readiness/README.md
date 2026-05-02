# 32_upgrade_patch_readiness

Version, plugin, invalid/risky object, charset/collation, and upgrade readiness checks.

Scripts in this area: `6`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 32_upgrade_patch_readiness/<script>.sql`.

## Scripts

- `01_version_upgrade_path_overview.sql`
- `02_plugin_version_drift_dependencies.sql`
- `03_preupgrade_invalid_objects_gate.sql`
- `04_charset_collation_mismatch_risk.sql`
- `05_postupgrade_statement_regression_watchlist.sql`
- `06_deprecated_variable_settings.sql`
