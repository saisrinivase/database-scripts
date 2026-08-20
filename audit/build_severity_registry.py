#!/usr/bin/env python3
"""Inventory severity labels and their visible decision criteria."""

from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MATRIX = ROOT / "audit" / "script-safety-matrix.tsv"
OUTPUT = ROOT / "audit" / "severity-filter-confidence-registry.tsv"
LABELS = r"CRITICAL|HIGH|MEDIUM|LOW|WARN(?:ING)?|REVIEW|OK"


def active_sql(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    return "\n".join(
        line for line in text.splitlines() if not line.lstrip().startswith("--")
    )


def compact(value: str, limit: int = 280) -> str:
    value = re.sub(r"\s+", " ", value).strip()
    return value if len(value) <= limit else value[: limit - 3] + "..."


def main() -> None:
    with MATRIX.open(newline="") as handle:
        matrix = {
            row["script"]: row for row in csv.DictReader(handle, delimiter="\t")
        }

    rows: list[list[str]] = []
    for path in sorted(
        p for p in ROOT.rglob("*.sql") if "audit" not in p.parts and ".git" not in p.parts
    ):
        rel = path.relative_to(ROOT).as_posix()
        sql = active_sql(path.read_text(errors="replace"))
        string_literals = re.findall(r"['\"]([^'\"]*)['\"]", sql)
        labels = sorted({
            label.upper()
            for literal in string_literals
            for label in re.findall(rf"\b({LABELS})\b", literal, re.I)
        })
        conditions = [
            compact(match)
            for match in re.findall(
                rf"\bWHEN\s+((?:(?!\bWHEN\b|\bELSE\b|\bEND\b).)+?)\s+THEN\s+['\"](?:{LABELS})(?:[^'\"]*)['\"]",
                sql,
                flags=re.I | re.S,
            )
        ]
        conditions = list(dict.fromkeys(conditions))[:8]
        filters = []
        for line in sql.splitlines():
            normalized = compact(line)
            if re.match(r"^(WHERE|AND|OR)\b", normalized, re.I) and re.search(
                r"(?:[<>]=?|\bBETWEEN\b|\bIN\s*\(|\bIS\s+(?:NOT\s+)?NULL\b|\binterval\b)",
                normalized,
                re.I,
            ):
                filters.append(normalized)
        filters = list(dict.fromkeys(filters))[:8]
        overrides = sorted(set(re.findall(r"current_setting\(['\"](pgdiag\.[^'\"]+)", sql, re.I)))

        has_numeric_or_interval = any(
            re.search(r"\d|interval|current_setting", item, re.I)
            for item in conditions + filters
        )
        if not labels:
            filter_design = "NO_SEVERITY_LABEL"
        elif overrides:
            filter_design = "CONFIGURABLE_OVERRIDE"
        elif has_numeric_or_interval:
            filter_design = "HARDCODED_THRESHOLD"
        elif conditions:
            filter_design = "STATE_OR_BOOLEAN_RULE"
        else:
            filter_design = "ADVISORY_LABEL_ONLY"

        evidence = matrix[rel]["evidence_basis"]
        validation = matrix[rel]["validation_level"]
        if not labels:
            evaluation_confidence = "NOT_APPLICABLE"
            confidence_reason = "No severity label is emitted by active SQL."
            root_cause_confidence = "NOT_APPLICABLE"
        elif not conditions:
            evaluation_confidence = "LOW"
            confidence_reason = "Severity wording exists but no CASE threshold was mechanically traceable; manual interpretation is required."
            root_cause_confidence = "LOW"
        elif evidence in {"CATALOG_OR_CONFIGURATION_FACT", "LIVE_INSTANCE_SNAPSHOT"}:
            evaluation_confidence = "HIGH"
            confidence_reason = "The rule is explicit and evaluates current catalog/configuration or live-state evidence."
            root_cause_confidence = "MEDIUM" if validation == "SCENARIO_VALIDATED" else "LOW"
        elif evidence in {"CUMULATIVE_INSTANCE_COUNTER", "CUMULATIVE_PG_STAT_STATEMENTS", "PLANNER_OR_MAINTENANCE_ESTIMATE", "REPOSITORY_HISTORY"}:
            evaluation_confidence = "MEDIUM"
            confidence_reason = "The rule is explicit, but its input is cumulative, sampled, estimated, or capture-cadence dependent."
            root_cause_confidence = "MEDIUM" if validation == "SCENARIO_VALIDATED" else "LOW"
        else:
            evaluation_confidence = "LOW"
            confidence_reason = "The rule requires external/provider evidence or is a lab/advisory workflow."
            root_cause_confidence = "LOW"

        rows.append([
            rel,
            ",".join(labels) or "none",
            filter_design,
            "; ".join(overrides) or "none",
            " || ".join(conditions) or "none mechanically extracted",
            " || ".join(filters) or "none mechanically extracted",
            evidence,
            evaluation_confidence,
            root_cause_confidence,
            confidence_reason,
            matrix[rel]["interpretation_limit"],
            "MANUALLY_VERIFIED_AND_RUNTIME_TESTED"
            if rel == "39_observer_agent_monitoring/04_active_incident_detector.sql"
            else "MECHANICALLY_EXTRACTED_REVIEW_REQUIRED",
        ])

    with OUTPUT.open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow([
            "script",
            "active_severity_or_advisory_keywords",
            "filter_design",
            "configurable_settings",
            "severity_conditions",
            "row_filter_criteria",
            "evidence_basis",
            "rule_evaluation_confidence",
            "root_cause_confidence",
            "confidence_reason",
            "interpretation_limit",
            "threshold_review_status",
        ])
        writer.writerows(rows)
    print(f"wrote {len(rows)} rows to {OUTPUT}")


if __name__ == "__main__":
    main()
