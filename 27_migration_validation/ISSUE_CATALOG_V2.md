# Migration Validation V2 Issue Catalog

Purpose: enterprise-style catalog mapping each issue to business impact, deterministic seed coverage, detection, and fix path.

## Coverage Grid

| Issue ID | Area | Severity | What It Means | Seeded in V2 | Detect With | Fix With |
|---|---|---|---|---|---|---|
| MV2-OBJ-001 | Schema Design | Critical | User table missing primary key | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-OBJ-002 | Referential Integrity | High | FK exists without supporting index | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-OBJ-003 | Index Hygiene | Medium | Duplicate index definitions consume write budget | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-OBJ-004 | Naming Standards | Medium | Uppercase quoted object names increase SQL fragility | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-OBJ-005 | Sequence Lifecycle | High | Sequence not owned by table column (orphan risk) | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-STAT-001 | Planner Stats | High | High modifications with stale analyze statistics | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-MAINT-001 | Storage Health | High | Dead tuple pressure indicates vacuum lag/bloat risk | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-DATA-001 | Data Quality | High | Empty-string values where NULL semantics were expected from Oracle | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-DATA-002 | Data Type Mapping | High | Numeric-overflow candidate (value exceeds modeled target range) | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-PERF-001 | Query Performance | Medium | Large table with no selective index candidate | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-PERF-002 | Search Performance | Medium | LIKE/ILIKE path without trigram support/index | Yes | `09_oracle_to_postgres_360_health_report_enterprise.sql` | `07_fix_v2_test_issues.sql` |
| MV2-CFG-001 | Configuration | Critical | autovacuum disabled | No (env-level) | `09_oracle_to_postgres_360_health_report_enterprise.sql` | Parameter change |
| MV2-CFG-002 | Observability | Medium | track_io_timing disabled reduces diagnostics quality | No (env-level) | `09_oracle_to_postgres_360_health_report_enterprise.sql` | Parameter change |
| MV2-EXT-001 | Extension Baseline | Medium | pg_stat_statements missing | No (env-level) | `09_oracle_to_postgres_360_health_report_enterprise.sql` | Extension install |

## Execution Workflow

1. Seed deterministic issues: `06_seed_v2_test_issues.sql`
2. Run enterprise report: `09_oracle_to_postgres_360_health_report_enterprise.sql`
3. Run assertions: `08_v2_sanity_checks.sql`
4. Apply fixes: `07_fix_v2_test_issues.sql`
5. Re-run report and assertions to verify all expected issues are resolved.

## Notes

- V2 seeds are fully isolated in schema `migration_v2_lab`.
- Environment-level checks (config/extensions) are not auto-seeded to avoid side effects on local clusters.
