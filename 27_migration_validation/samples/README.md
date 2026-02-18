# V1 Sample Artifacts

Generated on: `2026-02-18` (local PostgreSQL 18 test instance).

## Files

- `v1_report_before_fix.html`
- `v1_report_after_fix.html`
- `v1_sanity_before_fix.txt`
- `v1_sanity_after_fix.txt`

## Summary

- Main 360 report (`Overall Health Summary`)
  - Before fix: `total=23`, `pass=13`, `warn=10`, `fail=0`
  - After fix: `total=23`, `pass=19`, `warn=4`, `fail=0`
- V1 seeded sanity checks (`04_v1_sanity_checks.sql`)
  - Before fix: `total=7`, `pass=0`, `fail=7`, `all_passed=NO`
  - After fix: `total=7`, `pass=7`, `fail=0`, `all_passed=YES`

## Why warnings remain after fix

The remaining WARN checks are environment-level defaults in this local test instance (for example `track_io_timing`, `WAL/checkpoint baseline`, `replication topology`, and cache ratio), not unresolved seeded migration issues.
