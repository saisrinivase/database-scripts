# Sample Outputs - Object Inventory and Health

Database: `pgbench_test`  
Executed at: `2026-02-18 18:35:51 EST`

## Validation Result

- Scripts executed: `18`
- Success: `18`
- Failure: `0`
- Exit summary: `summary.tsv`

## Key Findings Snapshot

- Missing primary key candidate:
  - `public.pgbench_history`
- Missing join-column index candidate:
  - `migration_v2_lab.order_fact(account_id)`
- Identifier casing risk:
  - `migration_v2_lab."QuotedOrders_pkey"`
- Sequence ownership:
  - All detected sequences are `OWNED`.
- Grant exposure:
  - `7` high-risk `PUBLIC` grants detected (includes `pg_stat_statements` objects and migration_v2_lab routines).
- FDW status:
  - No FDW objects configured.
- KETTLE/ETL sessions:
  - No active KETTLE-like sessions detected during capture.
- Bloat hotspots (>=64MB tables):
  - `public.pgbench_accounts` and `public.pgbench_history`, both currently `LOW_BLOAT_PRESSURE` by dead-tuple ratio.

## How to Re-run

```bash
DB='pgbench_test'
ROOT='/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/29_object_inventory_health'
OUT="$ROOT/samples_20260218_pgbench_test"
for f in "$ROOT"/*.sql; do
  psql -d "$DB" -v ON_ERROR_STOP=1 -f "$f" > "$OUT/$(basename "${f%.sql}").out.txt" 2>&1
  echo "$(basename "$f")\t$?" >> "$OUT/summary.tsv"
done
```
