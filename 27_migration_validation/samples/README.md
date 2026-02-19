# Migration Validation Sample Artifacts

Purpose: store before/after evidence for migration validation workflows.

## V1 Samples (Available)

- `v1_report_before_fix.html`
- `v1_report_after_fix.html`
- `v1_sanity_before_fix.txt`
- `v1_sanity_after_fix.txt`

## V2 Samples (Generate in pgbench_test)

Recommended output names:

- `v2_report_before_fix.html`
- `v2_report_after_fix.html`
- `v2_sanity_before_fix.txt`
- `v2_sanity_after_fix.txt`

V2 scripts:

- Seed: `05_seed_v2_test_issues.sql`
- Report: `08_oracle_to_postgres_enterprise_report_v2.sql`
- Sanity: `07_v2_sanity_checks.sql`
- Fix: `06_fix_v2_test_issues.sql`

## V2 Practical Run Snapshot (pgbench_test)

- Enterprise report files:
  - `v2_report_before_fix.html`
  - `v2_report_after_fix.html`
- Sanity results:
  - Before fix: `total=11`, `pass=0`, `fail=11`, `all_passed=NO`
  - After fix: `total=11`, `pass=11`, `fail=0`, `all_passed=YES`

## V3 Takeover Gate Snapshot (pgbench_test)

- Gate output file:
  - `v3_takeover_gate_pgbench_test.txt`
- Decision:
  - `NO_GO`
- Summary:
  - `blocker_failures=2`
  - `warning_checks=2`
- Enforcement behavior:
  - Non-zero exit in pipeline mode when `enforce_exit=true`.
