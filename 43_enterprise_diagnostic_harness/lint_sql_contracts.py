#!/usr/bin/env python3
"""Enforce repository-wide diagnostic SQL conventions before execution."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
REQUIRED_HEADER_GROUPS = {
    "script title": re.compile(r"PostgreSQL DBA Script:", re.IGNORECASE),
    "purpose": re.compile(r"^\s*Purpose:", re.MULTILINE | re.IGNORECASE),
    "area or scope": re.compile(r"^\s*(?:Area|Scope):", re.MULTILINE | re.IGNORECASE),
    "usage or pgAdmin execution": re.compile(r"^\s*(?:Usage|pgAdmin):", re.MULTILINE | re.IGNORECASE),
    "sample output": re.compile(r"^\s*Sample Output:", re.MULTILINE | re.IGNORECASE),
    "notes, scope, or pgAdmin caveat": re.compile(r"^\s*(?:Notes|Scope|pgAdmin):", re.MULTILINE | re.IGNORECASE),
}
PSQL_META = re.compile(r"^\s*\\(?:gset|if|else|endif|set|pset|echo)\b", re.MULTILINE | re.IGNORECASE)
THREE_MONTH_WINDOW = re.compile(r"interval\s+'\s*(?:3\s*months?|90\s*days?)\s*'", re.IGNORECASE)
MISLEADING_EXECUTABLE_LABELS = {
    "pct_memory_spill": re.compile(r"\bpct_memory_spill\b", re.IGNORECASE),
    "memory-tier temp-spill label": re.compile(r"['\"]MEMORY(?:/|-)?(?:TEMP-)?SPILL", re.IGNORECASE),
}


def sql_files() -> list[Path]:
    return sorted(
        path for path in REPO_ROOT.rglob("*.sql")
        if "_validation_runs" not in path.parts and "/samples_" not in path.as_posix()
    )


def main() -> int:
    failures: list[str] = []
    for path in sql_files():
        text = path.read_text(encoding="utf-8")
        relative = path.relative_to(REPO_ROOT)
        missing = [label for label, pattern in REQUIRED_HEADER_GROUPS.items() if not pattern.search(text)]
        if missing:
            failures.append(f"{relative}: missing required header content: {', '.join(missing)}")
        has_sample_markers = "SAMPLE_OUTPUT_BEGIN" in text and "SAMPLE_OUTPUT_END" in text
        has_inline_sample = re.search(r"^\s*Sample Output:", text, re.MULTILINE | re.IGNORECASE)
        if not has_sample_markers and not has_inline_sample:
            failures.append(f"{relative}: missing sample output evidence")
        if PSQL_META.search(text):
            failures.append(f"{relative}: contains psql-only meta command")
        # Retention policy is allowed; fixed reporting horizons must be explicit in the header.
        if THREE_MONTH_WINDOW.search(text) and "Retention" not in text and "History Window:" not in text:
            failures.append(f"{relative}: fixed 3-month/90-day window needs a History Window: header")
        executable = text.split("-- SAMPLE_OUTPUT_BEGIN", 1)[0]
        for label, pattern in MISLEADING_EXECUTABLE_LABELS.items():
            if pattern.search(executable):
                failures.append(f"{relative}: misleading executable label: {label}")

    if failures:
        print("Repository contract check failed:", file=sys.stderr)
        print("\n".join(f"- {failure}" for failure in failures), file=sys.stderr)
        return 1
    print(f"Repository contract check passed for {len(sql_files())} SQL scripts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
