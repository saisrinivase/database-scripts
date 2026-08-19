#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "audit" / "script-safety-matrix.tsv"
READONLY_RESULTS = ROOT / "audit" / "results-readonly-after-setup" / "readonly-results.tsv"
DISPOSABLE_RESULTS = ROOT / "audit" / "results-disposable-final" / "disposable-results.tsv"
PG_MONITOR_RESULTS = ROOT / "audit" / "results-pg-monitor-final" / "readonly-results.tsv"


def readonly_failures() -> set[str]:
    if not READONLY_RESULTS.exists():
        return set()
    with READONLY_RESULTS.open(newline="") as handle:
        return {
            row["script"]
            for row in csv.DictReader(handle, delimiter="\t")
            if row["result"] == "FAIL"
        }


def load_result(path: Path, result_column: str = "result") -> dict[str, str]:
    if not path.exists():
        return {}
    with path.open(newline="") as handle:
        return {row["script"]: row[result_column] for row in csv.DictReader(handle, delimiter="\t")}


def active_sql(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    return "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("--"))


def contains(sql: str, pattern: str) -> bool:
    return re.search(pattern, sql, flags=re.I | re.S) is not None


def classify(
    path: Path,
    reader_incompatible: set[str],
    disposable_results: dict[str, str],
    pg_monitor_results: dict[str, str],
) -> list[str]:
    rel = path.relative_to(ROOT).as_posix()
    text = path.read_text(errors="replace")
    sql = active_sql(text)

    persistent_write = contains(
        sql,
        r"\b(create\s+(?:schema|table|index|view|procedure|event\s+trigger)|"
        r"alter\s+table|drop\s+(?:schema|table|index|view)|truncate\s+(?!pg_temp)|"
        r"insert\s+into\s+(?!pg_temp\b|[a-z_][\w$]*_result\b|obs360_)|"
        r"update\s+(?!pg_temp\b)|delete\s+from\s+(?!pg_temp\b)|"
        r"call\s+(?!pg_temp\.)|vacuum\b|reindex\b|cluster\b|refresh\s+materialized)"
    )
    temp_ddl = contains(sql, r"\b(create(?:\s+or\s+replace)?\s+(?:temp(?:orary)?\s+)?(?:table|function)|drop\s+table)\b")
    creates_temp = contains(sql, r"\b(?:pg_temp\.|create\s+temp(?:orary)?\s+(?:table|function))")
    changes_session = contains(sql, r"\b(?:set|reset)\s+[a-z_]\w*")

    standby_specific = contains(sql, r"\b(pg_last_wal_(?:receive|replay)_lsn|pg_last_xact_replay_timestamp|pg_stat_wal_receiver)\b")
    primary_specific = contains(sql, r"\b(pg_current_wal_(?:lsn|insert_lsn|flush_lsn)|pg_stat_replication|pg_stat_archiver|pg_switch_wal)\b")

    local_runtime_stats = contains(
        sql,
        r"\b(pg_stat_activity|pg_locks|pg_stat_statements|pg_stat_(?:user|all)_(?:tables|indexes)|"
        r"pg_statio_|pg_stat_database|pg_stat_io|pg_backend_memory_contexts)\b"
    )
    writer_maintenance_stats = contains(
        sql,
        r"\b(n_dead_tup|last_autovacuum|autovacuum_count|vacuum_count|relfrozenxid|relminmxid|"
        r"pg_stat_progress_vacuum|pg_stat_archiver|pg_stat_wal)\b"
    )

    if rel in reader_incompatible:
        placement = "WRITER_ONLY"
        placement_reason = "Empirically rejected by PostgreSQL read-only execution after prerequisites were installed."
    elif standby_specific and not primary_specific:
        placement = "READER_PREFERRED"
        placement_reason = "Uses standby receive/replay state."
    elif primary_specific and not standby_specific:
        placement = "WRITER_PREFERRED"
        placement_reason = "Uses primary WAL/archive/sender state."
    elif primary_specific and standby_specific:
        placement = "RUN_ON_BOTH"
        placement_reason = "Contains both primary and standby evidence; compare writer and reader output."
    elif writer_maintenance_stats:
        placement = "WRITER_REQUIRED"
        placement_reason = "Writer-local DML, vacuum, WAL, or maintenance statistics are authoritative."
    elif local_runtime_stats:
        placement = "TARGET_INSTANCE"
        placement_reason = "Runtime counters are instance-local; run on the writer or reader whose workload is being diagnosed."
    else:
        placement = "EITHER_METADATA"
        placement_reason = "Catalog/metadata diagnostic; a sufficiently current reader can offload the writer."

    relation_scan = contains(sql, r"\bfrom\s+(?:pg_catalog\.)?pg_largeobject\b")
    size_calls = len(re.findall(r"\bpg_(?:total_relation|relation|indexes|database|tablespace)_size\s*\(", sql, flags=re.I))
    all_relations = contains(sql, r"\bfrom\s+(?:pg_catalog\.)?pg_class\b")
    stats_history = contains(sql, r"\bpg_stat_statements\b")
    interval_sample = contains(sql, r"\bpg_sleep\s*\(")
    explain_analyze = contains(sql, r"\bexplain\s*\([^)]*analyze|\bexplain\s+analyze")
    generator = contains(sql, r"\bgenerate_series\s*\(")
    full_sort = contains(sql, r"\border\s+by\b") and not contains(sql, r"\blimit\s+\d+")

    lab_scripts = {
        "37_object_lifecycle_capacity/11_index_usage_lab_create_use_drop_demo.sql",
        "37_object_lifecycle_capacity/12_table_modification_tracking_demo.sql",
    }
    if rel == "05_partitioning/07_partition_lab_generate_5gb_timeseries.sql":
        scale_class = "PROHIBITED_PRODUCTION"
        scale_reason = "Destructive lab: drops/recreates a persistent table and writes at least 5 GiB."
    elif rel in lab_scripts:
        scale_class = "LAB_ONLY"
        scale_reason = "Persistent workload generator/demo; use only in an isolated disposable database."
    elif relation_scan:
        scale_class = "LOW"
        scale_reason = "Scans pg_largeobject data; runtime is proportional to large-object volume."
    elif interval_sample:
        scale_class = "MEDIUM"
        scale_reason = "Interval sampler holds a session; control frequency and concurrency."
    elif size_calls and all_relations:
        scale_class = "MEDIUM"
        scale_reason = "Calls size functions across relation catalogs; cost grows with object/segment count."
    elif contains(sql, r"\bpg_database_size\s*\("):
        scale_class = "MEDIUM"
        scale_reason = "Database-size traversal can be expensive with many files/segments or databases."
    elif stats_history and full_sort:
        scale_class = "MEDIUM_HIGH"
        scale_reason = "Scans/sorts pg_stat_statements; bounded by tracked statement cardinality, not table TB."
    elif all_relations or full_sort:
        scale_class = "MEDIUM_HIGH"
        scale_reason = "Catalog/statistics-wide query; scales with object/session/statistics cardinality."
    else:
        scale_class = "HIGH"
        scale_reason = "Bounded catalog/statistics query; not proportional to user-table bytes."

    if scale_class == "HIGH":
        confidence_10tb, confidence_50tb = "HIGH", "HIGH"
    elif scale_class == "MEDIUM_HIGH":
        confidence_10tb, confidence_50tb = "HIGH", "MEDIUM_HIGH"
    elif scale_class == "MEDIUM":
        confidence_10tb, confidence_50tb = "MEDIUM_HIGH", "MEDIUM"
    elif scale_class == "LOW":
        confidence_10tb, confidence_50tb = "LOW", "LOW"
    else:
        confidence_10tb, confidence_50tb = "NO", "NO"

    prerequisites = []
    if stats_history:
        prerequisites.append("pg_stat_statements")
    if contains(sql, r"\bpg_stat_io\b"):
        prerequisites.append("PostgreSQL 16+")
    if contains(sql, r"\bpg_stat_checkpointer\b"):
        prerequisites.append("PostgreSQL 17+ or guarded fallback")
    if contains(sql, r"\bpgstattuple|pgstatindex\b"):
        prerequisites.append("pgstattuple extension")
    if contains(sql, r"\bpgaudit\b"):
        prerequisites.append("pgAudit package/preload for audit events")
    if contains(sql, r"\bbt_index_|verify_heapam\b"):
        prerequisites.append("amcheck extension")
    if contains(sql, r"\bpg_visibility\b"):
        prerequisites.append("pg_visibility extension")
    if persistent_write:
        prerequisites.append("DDL/DML privileges")
    elif temp_ddl:
        prerequisites.append("TEMP privilege")

    risk_flags = []
    if persistent_write:
        risk_flags.append("PERSISTENT_WRITE")
    if temp_ddl:
        risk_flags.append("TEMP_DDL")
    if relation_scan:
        risk_flags.append("DATA_SCAN")
    if size_calls:
        risk_flags.append("SIZE_CALL_LOOP" if all_relations else "SIZE_CALL")
    if stats_history:
        risk_flags.append("PGSS_SCAN")
    if changes_session:
        risk_flags.append("SESSION_SETTING")
    if generator:
        risk_flags.append("DATA_GENERATOR")
    if explain_analyze:
        risk_flags.append("EXECUTES_QUERY")

    return [
        rel,
        placement,
        placement_reason,
        scale_class,
        confidence_10tb,
        confidence_50tb,
        scale_reason,
        ",".join(prerequisites) or "none",
        ",".join(risk_flags) or "none",
        disposable_results.get(rel, "NOT_RUN"),
        "FAIL" if rel in reader_incompatible else "PASS",
        pg_monitor_results.get(rel, "NOT_RUN"),
    ]


def main() -> None:
    scripts = sorted(p for p in ROOT.rglob("*.sql") if "audit" not in p.parts and ".git" not in p.parts)
    reader_incompatible = readonly_failures()
    disposable_results = load_result(DISPOSABLE_RESULTS)
    pg_monitor_results = load_result(PG_MONITOR_RESULTS)
    OUT.parent.mkdir(exist_ok=True)
    with OUT.open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow([
            "script", "placement", "placement_reason", "scale_class",
            "confidence_10tb", "confidence_50tb", "scale_reason",
            "prerequisites", "risk_flags", "disposable_runtime",
            "read_only_runtime", "pg_monitor_runtime",
        ])
        writer.writerows(
            classify(path, reader_incompatible, disposable_results, pg_monitor_results)
            for path in scripts
        )
    print(f"wrote {len(scripts)} rows to {OUT}")


if __name__ == "__main__":
    main()
