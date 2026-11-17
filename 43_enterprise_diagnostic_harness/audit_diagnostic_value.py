#!/usr/bin/env python3
"""Audit every SQL script for diagnostic benefit, evidence quality, and common overclaims."""

from __future__ import annotations

import argparse
import re
from collections import Counter
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SAMPLE_BEGIN = "-- SAMPLE_OUTPUT_BEGIN"
SAMPLE_END = "-- SAMPLE_OUTPUT_END"


@dataclass
class AuditRow:
    script: str
    purpose: str
    evidence_class: str
    confidence: str
    prerequisites: str
    flags: list[str]

    @property
    def status(self) -> str:
        if any(flag in {"RESOURCE_PROXY_NAMED_AS_EXACT", "QUERY_TEXT_TRUNCATED"} for flag in self.flags):
            return "BLOCK"
        if self.flags:
            return "REVIEW"
        return "PASS"


def header_value(text: str, label: str) -> str:
    match = re.search(rf"^\s*{re.escape(label)}:\s*(.+?)\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else "Not documented"


def executable_text(text: str) -> str:
    before_sample = text.split(SAMPLE_BEGIN, 1)[0]
    without_block_comments = re.sub(r"/\*.*?\*/", "", before_sample, flags=re.DOTALL)
    return re.sub(r"--[^\n]*", "", without_block_comments)


def evidence_class(path: Path, purpose: str, sql: str) -> tuple[str, str]:
    joined = f"{path.as_posix()} {purpose}".lower()
    low = sql.lower()
    if any(term in joined for term in ("lab", "demo", "create repository", "capture snapshot", "scheduler runbook")):
        return "Controlled workflow", "Depends on workflow completion and stated prerequisites"
    if "pg_sleep(" in low or ("lag(" in low and "elapsed" in low) or "delta" in joined:
        return "Interval measurement", "90-98% when reset checks and elapsed time are valid"
    if any(term in joined for term in (
        "candidate", "advisor", "recommendation", "risk", "bloat", "hotspot", "scorecard", "classification"
    )):
        return "Heuristic candidate", "65-85%; requires plan/workload validation"
    if re.search(r"\bpg_stat_(statements|database|user_|all_|wal|bgwriter|checkpointer|archiver|io)", low):
        return "Cumulative counter", "85-95% with a known reset-bounded observation window"
    if re.search(r"\bpg_stat_(activity|progress_|replication|subscription)|\bpg_locks\b", low):
        return "Point-in-time state", "90-98% for the captured instant"
    return "Direct catalog fact", "95-99% when permissions expose the required catalogs"


def prerequisites(sql: str, header: str) -> str:
    low = f"{sql} {header}".lower()
    found: list[str] = []
    for token, label in (
        ("pg_stat_statements", "pg_stat_statements"),
        ("pgstattuple", "pgstattuple"),
        ("pg_stat_io", "PostgreSQL 16+ pg_stat_io"),
        ("pg_backend_memory_contexts", "memory-context visibility"),
        ("pg_read_all_stats", "pg_read_all_stats/pg_monitor"),
        ("dba_metrics", "repository setup"),
        ("dba_lifecycle", "lifecycle repository setup"),
        ("dba_observer", "observer repository setup"),
    ):
        if token in low and label not in found:
            found.append(label)
    return ", ".join(found) if found else "Core PostgreSQL catalogs"


def sample_line_count(text: str) -> int:
    if SAMPLE_BEGIN not in text or SAMPLE_END not in text:
        return 0
    sample = text.split(SAMPLE_BEGIN, 1)[1].split(SAMPLE_END, 1)[0]
    return sample.count("\n")


def audit_flags(text: str, sql: str) -> list[str]:
    low = sql.lower()
    documented = text.split(SAMPLE_BEGIN, 1)[0].lower()
    flags: list[str] = []
    if sample_line_count(text) > 80:
        flags.append("OVERSIZED_SAMPLE")
    if re.search(r"\b(from|join)\s+pg_stat_statements\b", low) and not re.search(
        r"pg_stat_statements_info|stats_reset|statistics_age", low
    ):
        flags.append("CUMULATIVE_WINDOW_NOT_EXPOSED")
    if re.search(
        r"\b(left|substr|substring)\s*\([^\n]*(query|statement|sql)[^\n]*\)\s+as\s+"
        r"(query|statement|sql)[a-z0-9_]*",
        low,
    ):
        flags.append("QUERY_TEXT_TRUNCATED")
    if re.search(r"\bas\s+(cpu_pct|cpu_percent|cpu_share_pct|memory_pct|memory_percent)\b", low):
        flags.append("RESOURCE_PROXY_NAMED_AS_EXACT")
    if re.search(r"\bas\s+(recommended_action|recommendation)\b", low) and not re.search(
        r"explain|validate|verify|review|inspect|correlate|measure", documented
    ):
        flags.append("ACTION_WITHOUT_VALIDATION_STEP")
    return flags


def audit() -> list[AuditRow]:
    rows: list[AuditRow] = []
    for path in sorted(REPO_ROOT.rglob("*.sql")):
        if ".git" in path.parts or "_validation_runs" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        sql = executable_text(text)
        purpose = header_value(text, "Purpose")
        evidence, confidence = evidence_class(path.relative_to(REPO_ROOT), purpose, sql)
        rows.append(AuditRow(
            script=path.relative_to(REPO_ROOT).as_posix(),
            purpose=purpose,
            evidence_class=evidence,
            confidence=confidence,
            prerequisites=prerequisites(sql, text.split("*/", 1)[0]),
            flags=audit_flags(text, sql),
        ))
    return rows


def md_escape(value: str) -> str:
    return value.replace("|", "\\|").replace("\n", " ")


def render(rows: list[AuditRow]) -> str:
    statuses = Counter(row.status for row in rows)
    flags = Counter(flag for row in rows for flag in row.flags)
    lines = [
        "# PostgreSQL Script Accuracy And Benefit Audit",
        "",
        "This register is generated by `43_enterprise_diagnostic_harness/audit_diagnostic_value.py`.",
        "Execution success proves that SQL runs; it does not prove a diagnosis. `BLOCK` identifies misleading",
        "resource naming or truncated evidence. `REVIEW` identifies an interpretation or maintainability gap.",
        "Confidence ranges are engineering guidance, not statistical guarantees.",
        "",
        "## Summary",
        "",
        f"- Scripts audited: `{len(rows)}`",
        f"- PASS: `{statuses['PASS']}`; REVIEW: `{statuses['REVIEW']}`; BLOCK: `{statuses['BLOCK']}`",
    ]
    for flag, count in sorted(flags.items()):
        lines.append(f"- `{flag}`: `{count}`")
    lines.extend([
        "",
        "## Per-Script Register",
        "",
        "| Status | Script | Benefit | Evidence | Confidence boundary | Prerequisites | Review flags |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ])
    for row in rows:
        lines.append(
            f"| {row.status} | `{row.script}` | {md_escape(row.purpose)} | {row.evidence_class} | "
            f"{md_escape(row.confidence)} | {md_escape(row.prerequisites)} | "
            f"{', '.join(f'`{flag}`' for flag in row.flags) or '-'} |"
        )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", default="SCRIPT_ACCURACY_BENEFIT_AUDIT.md")
    parser.add_argument("--check", action="store_true", help="Do not write; fail when BLOCK findings exist")
    parser.add_argument("--strict", action="store_true", help="With --check, also fail when REVIEW findings exist")
    args = parser.parse_args()
    rows = audit()
    blocked = [row for row in rows if row.status == "BLOCK"]
    if not args.check:
        report = (REPO_ROOT / args.report).resolve()
        report.write_text(render(rows), encoding="utf-8")
        print(f"Wrote {report}")
    print(
        f"Audited {len(rows)} scripts: "
        f"{sum(row.status == 'PASS' for row in rows)} PASS, "
        f"{sum(row.status == 'REVIEW' for row in rows)} REVIEW, {len(blocked)} BLOCK"
    )
    for row in blocked:
        print(f"BLOCK {row.script}: {', '.join(row.flags)}")
    review = [row for row in rows if row.status == "REVIEW"]
    return 1 if args.check and (blocked or (args.strict and review)) else 0


if __name__ == "__main__":
    raise SystemExit(main())
