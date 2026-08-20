#!/usr/bin/env python3
"""Build bounded psql master files for cross-database read-only certification."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MATRIX = ROOT / "audit" / "script-safety-matrix.tsv"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("database")
    parser.add_argument("output")
    args = parser.parse_args()

    output = Path(args.output).resolve()
    with MATRIX.open(newline="") as handle:
        scripts = [
            row["script"]
            for row in csv.DictReader(handle, delimiter="\t")
            if row["read_only_runtime"] == "PASS"
        ]

    lines = [
        r"\set ON_ERROR_STOP off",
        r"\set VERBOSITY terse",
        r"\set QUIET on",
        f"\\connect {args.database}",
        "SET application_name = 'database_scripts_cross_database_audit';",
        "SET default_transaction_read_only = on;",
        "SET statement_timeout = '15s';",
        "SET lock_timeout = '1s';",
        "SET idle_in_transaction_session_timeout = '30s';",
        "SET temp_file_limit = '128MB';",
        r"\o /dev/null",
    ]
    for script in scripts:
        path = ROOT / script
        lines.extend(
            [
                f"\\echo AUDIT_BEGIN|{script}",
                "BEGIN READ ONLY;",
                f"\\i {path}",
                "ROLLBACK;",
                f"\\echo AUDIT_END|{script}",
            ]
        )
    output.write_text("\n".join(lines) + "\n")
    print(f"wrote {len(scripts)} scripts for {args.database} to {output}")


if __name__ == "__main__":
    main()
