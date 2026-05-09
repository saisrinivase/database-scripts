/*
Purpose: pgAdmin-safe replication and HA dashboard for primary or standby servers.
Scope: Recovery role, physical replication lag, receiver status, slots, and HA risk signals.
pgAdmin: Safe to run in Query Tool.
Sample output:
 section       | object_name | metric_name       | metric_value | diagnosis
---------------+-------------+-------------------+--------------+----------------------------
 role          | current db  | pg_is_in_recovery | 0            | Primary server.
 replication   | standby1    | replay_lag_bytes  | 8192         | Lag is currently low.
*/

WITH role_state AS (
    SELECT
        CASE WHEN pg_is_in_recovery() THEN 'standby' ELSE 'primary' END AS server_role
),
replication AS (
    SELECT
        application_name::text AS object_name,
        client_addr::text AS client_addr,
        state::text AS state,
        sync_state::text AS sync_state,
        pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn)::numeric AS sent_lag_bytes,
        pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)::numeric AS replay_lag_bytes
    FROM pg_stat_replication
),
slots AS (
    SELECT
        slot_name::text AS object_name,
        slot_type::text,
        active,
        restart_lsn,
        CASE
            WHEN restart_lsn IS NULL THEN NULL::numeric
            WHEN pg_is_in_recovery() THEN NULL::numeric
            ELSE pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)::numeric
        END AS retained_wal_bytes
    FROM pg_replication_slots
)
SELECT
    'role'::text AS section,
    current_database()::text AS object_name,
    'server_role'::text AS metric_name,
    CASE WHEN server_role = 'primary' THEN 0::numeric ELSE 1::numeric END AS metric_value,
    server_role::text AS metric_text,
    CASE WHEN server_role = 'primary' THEN 'Primary server. Review senders and slots.' ELSE 'Standby server. Review receiver and replay delay.' END::text AS diagnosis
FROM role_state
UNION ALL
SELECT
    'replication',
    object_name,
    'replay_lag_bytes',
    replay_lag_bytes,
    concat_ws(', ', 'client=' || client_addr, 'state=' || state, 'sync=' || sync_state),
    CASE
        WHEN replay_lag_bytes > 1024 * 1024 * 1024 THEN 'High replay lag. Check standby apply rate, network, WAL volume, and locks.'
        WHEN state IS DISTINCT FROM 'streaming' THEN 'Replica is not streaming. Investigate connectivity and WAL availability.'
        ELSE 'Replica lag is currently low or normal.'
    END
FROM replication
UNION ALL
SELECT
    'slot',
    object_name,
    'retained_wal_bytes',
    retained_wal_bytes,
    concat_ws(', ', 'type=' || slot_type, 'active=' || active::text),
    CASE
        WHEN retained_wal_bytes > 10::numeric * 1024 * 1024 * 1024 THEN 'Slot is retaining significant WAL. Validate consumer health urgently.'
        WHEN active = false THEN 'Inactive replication slot can retain WAL. Drop unused slots after confirmation.'
        ELSE 'Replication slot is active or low risk.'
    END
FROM slots
UNION ALL
SELECT
    'wal_receiver',
    coalesce(conninfo, 'no wal receiver')::text,
    'receiver_status',
    NULL::numeric,
    coalesce(status, 'not receiving')::text,
    CASE WHEN status = 'streaming' THEN 'Standby WAL receiver is streaming.' ELSE 'No active WAL receiver in this database session view.' END
FROM pg_stat_wal_receiver;

-- SAMPLE_OUTPUT_BEGIN
-- section     | object_name | metric_name      | metric_value | metric_text                  | diagnosis
-- ------------+-------------+------------------+--------------+------------------------------+------------------------------
-- role        | appdb       | server_role      | 0            | primary                      | Primary server...
-- replication | standby1    | replay_lag_bytes | 8192         | client=10.0.0.5, state=...   | Replica lag is currently low...
-- SAMPLE_OUTPUT_END
