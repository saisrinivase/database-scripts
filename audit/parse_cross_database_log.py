#!/usr/bin/env python3
"""Convert a marked psql cross-database log into a per-script TSV."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


BEGIN = re.compile(r"^AUDIT_BEGIN\|(.+)$")
END = re.compile(r"^AUDIT_END\|(.+)$")
ERROR = re.compile(r"(?:^|:)\s*(?:ERROR|FATAL|PANIC):", re.I)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("database")
    parser.add_argument("log")
    parser.add_argument("output")
    args = parser.parse_args()

    current: str | None = None
    evidence: list[str] = []
    rows: list[tuple[str, str, str]] = []
    for raw_line in Path(args.log).read_text(errors="replace").splitlines():
        line = raw_line.strip()
        begin = BEGIN.match(line)
        if begin:
            current = begin.group(1)
            evidence = []
            continue
        end = END.match(line)
        if end and current:
            errors = [item for item in evidence if ERROR.search(item)]
            missing_prerequisite = errors and all(
                ('relation "pg_stat_statements" does not exist' in item)
                or ('relation "dba_metrics.' in item and 'does not exist' in item)
                or ('extension' in item.lower() and 'does not exist' in item.lower())
                for item in errors
                if "current transaction is aborted" not in item
            )
            result = (
                "PREREQUISITE_NOT_MET"
                if missing_prerequisite
                else "FAIL" if errors else "PASS"
            )
            detail = " | ".join(errors[:3]) if errors else "-"
            rows.append((current, result, detail))
            current = None
            evidence = []
            continue
        if current:
            evidence.append(line)

    with Path(args.output).open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(["database", "script", "result", "error"])
        writer.writerows((args.database, *row) for row in rows)
    print(f"parsed {len(rows)} scripts: " + ", ".join(
        f"{result}={sum(row[1] == result for row in rows)}"
        for result in ("PASS", "PREREQUISITE_NOT_MET", "FAIL")
    ))


if __name__ == "__main__":
    main()
