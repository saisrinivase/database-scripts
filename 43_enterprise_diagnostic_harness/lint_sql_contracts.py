#!/usr/bin/env python3
"""Enforce repository-wide diagnostic SQL conventions before execution."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
REQUIRED_HEADERS = ("PostgreSQL DBA Script:", "Purpose:", "Area:", "Usage:", "Sample Output:", "Notes:")
PSQL_META = re.compile(r"^\s*\\(?:gset|if|else|endif|set|pset|echo)\b", re.MULTILINE | re.IGNORECASE)
THREE_MONTH_WINDOW = re.compile(r"interval\s+'\s*(?:3\s*months?|90\s*days?)\s*'", re.IGNORECASE)


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
        missing = [header for header in REQUIRED_HEADERS if header not in text]
        if missing:
            failures.append(f"{relative}: missing required header(s): {', '.join(missing)}")
        if "SAMPLE_OUTPUT_BEGIN" not in text or "SAMPLE_OUTPUT_END" not in text:
            failures.append(f"{relative}: missing SAMPLE_OUTPUT_BEGIN/SAMPLE_OUTPUT_END marker")
        if PSQL_META.search(text):
            failures.append(f"{relative}: contains psql-only meta command")
        # Retention policy is allowed; fixed reporting horizons must be explicit in the header.
        if THREE_MONTH_WINDOW.search(text) and "Retention" not in text and "History Window:" not in text:
            failures.append(f"{relative}: fixed 3-month/90-day window needs a History Window: header")

    if failures:
        print("Repository contract check failed:", file=sys.stderr)
        print("\n".join(f"- {failure}" for failure in failures), file=sys.stderr)
        return 1
    print(f"Repository contract check passed for {len(sql_files())} SQL scripts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
