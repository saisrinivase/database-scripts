# 16_internals_deep_dive

Undo, extents, segment internals, dependencies, LOB internals, and retention profiles.

Scripts in this area: `6`.

## Usage

Run with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @16_internals_deep_dive/<script>.sql`.

## Scripts

- `01_undo_transaction_age.sql`
- `02_segment_extent_mapping.sql`
- `03_system_catalog_size_profile.sql`
- `04_dependency_fanout_objects.sql`
- `05_segment_space_lob_breakdown.sql`
- `06_undo_retention_profile.sql`
