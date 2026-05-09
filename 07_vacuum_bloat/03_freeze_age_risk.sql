/*
PostgreSQL DBA Script: Freeze Age Risk
Purpose: Identify tables approaching anti-wraparound vacuum risk and explain operational impact if freeze age is ignored.
Area: Vacuum and Bloat
Usage: Review highest-risk tables first. Compare relfrozenxid age with autovacuum_freeze_max_age and clear blockers before emergency vacuum is needed.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. If freeze age is not controlled, PostgreSQL may force aggressive anti-wraparound vacuum; in severe cases the database can refuse writes to prevent transaction ID wraparound data corruption.
*/
WITH settings AS (
    SELECT current_setting('autovacuum_freeze_max_age')::numeric AS freeze_max_age
),
relation_age AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        age(c.relfrozenxid)::numeric AS relfrozenxid_age,
        age(t.relfrozenxid)::numeric AS toast_relfrozenxid_age,
        pg_total_relation_size(c.oid) AS total_bytes,
        greatest(
            age(c.relfrozenxid)::numeric,
            coalesce(age(t.relfrozenxid)::numeric, 0)
        ) AS max_freeze_age
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    LEFT JOIN pg_class t
        ON t.oid = c.reltoastrelid
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    r.schema_name,
    r.table_name,
    r.relfrozenxid_age::bigint AS relfrozenxid_age,
    r.toast_relfrozenxid_age::bigint AS toast_relfrozenxid_age,
    pg_size_pretty(r.total_bytes) AS total_size,
    s.freeze_max_age::bigint AS autovacuum_freeze_max_age,
    round(100.0 * r.max_freeze_age / NULLIF(s.freeze_max_age, 0), 2) AS freeze_age_pct_of_limit,
    CASE
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.90 THEN 'CRITICAL'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.75 THEN 'HIGH'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.50 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS freeze_risk_level,
    CASE
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.90
            THEN 'Immediate risk: PostgreSQL may launch aggressive anti-wraparound vacuum; if age continues, writes can be blocked to prevent XID wraparound.'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.75
            THEN 'High risk: autovacuum may become aggressive soon; long transactions or disabled vacuum can push the database toward write-protection.'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.50
            THEN 'Growing risk: freeze backlog is building; investigate autovacuum throughput before it becomes urgent.'
        ELSE 'Low current risk: continue normal monitoring and confirm autovacuum is enabled.'
    END AS what_happens_if_ignored,
    CASE
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.90
            THEN 'Clear idle-in-transaction blockers, run VACUUM FREEZE on the table during a safe window, and verify autovacuum is not disabled.'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.75
            THEN 'Prioritize VACUUM/FREEZE planning, check autovacuum settings per table, and review long-running transactions.'
        WHEN r.max_freeze_age >= s.freeze_max_age * 0.50
            THEN 'Monitor trend, validate autovacuum scale factors and freeze settings, and check table update/delete workload.'
        ELSE 'No immediate action beyond routine autovacuum monitoring.'
    END AS recommended_action
FROM relation_age r
CROSS JOIN settings s
ORDER BY r.max_freeze_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | table_name       | relfrozenxid_age | toast_relfrozenxid_age | total_size | autovacuum_freeze_max_age | freeze_age_pct_of_limit | freeze_risk_level | what_happens_if_ignored                         | recommended_action
-- -------------+------------------+------------------+------------------------+------------+---------------------------+-------------------------+-------------------+-------------------------------------------------+------------------------------
--  public      | pgbench_accounts |          5333873 |                        | 30 GB      |                 200000000 |                    2.67 | LOW               | Low current risk: continue normal monitoring... | No immediate action...
--  public      | pgbench_history  |          5333822 |                        | 270 MB     |                 200000000 |                    2.67 | LOW               | Low current risk: continue normal monitoring... | No immediate action...
--  public      | old_hot_table    |        182000000 |              182000000 | 80 GB      |                 200000000 |                   91.00 | CRITICAL          | Immediate risk: PostgreSQL may launch...        | Clear idle-in-transaction blockers...
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
