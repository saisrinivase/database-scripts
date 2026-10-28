#!/usr/bin/env python3
"""Validate PostgreSQL diagnostics without leaving persistent changes behind."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
STATEFUL_AREAS = {
    "15_capacity_forecasting",
    "37_object_lifecycle_capacity",
    "39_observer_agent_monitoring",
}
EXCLUDED_NAME_PARTS = ("_lab_", "_demo_", "generate_5gb", "/samples_")


def discover_scripts(relative_path: str | None, include_stateful: bool) -> list[Path]:
    root = (REPO_ROOT / relative_path).resolve() if relative_path else REPO_ROOT
    if REPO_ROOT not in (root, *root.parents):
        raise ValueError("--path must stay inside the repository")
    candidates = [root] if root.is_file() else sorted(root.rglob("*.sql"))
    scripts: list[Path] = []
    for script in candidates:
        relative = script.relative_to(REPO_ROOT)
        if "_validation_runs" in relative.parts:
            continue
        if not include_stateful and relative.parts[0] in STATEFUL_AREAS:
            continue
        normalized = "/" + relative.as_posix()
        if any(part in normalized for part in EXCLUDED_NAME_PARTS):
            continue
        scripts.append(script)
    return scripts


def psql_base(database: str, psql_path: str) -> list[str]:
    return [psql_path, "-X", "-v", "ON_ERROR_STOP=1", "--dbname", database]


def server_identity(database: str, psql_path: str) -> dict[str, str]:
    query = (
        "SELECT json_build_object("
        "'server_version_num', current_setting('server_version_num'), "
        "'server_version', version(), "
        "'database', current_database(), "
        "'user', current_user, "
        "'recovery', pg_is_in_recovery())::text;"
    )
    result = subprocess.run(
        [*psql_base(database, psql_path), "-Atqc", query],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or "Unable to connect with psql")
    return json.loads(result.stdout.strip())


def driver_text(script: Path, statement_timeout: str, lock_timeout: str) -> str:
    # A transaction catches accidental persistent DDL/DML and removes pg_temp helpers.
    return (
        "\\set ON_ERROR_STOP on\n"
        "BEGIN;\n"
        f"SET LOCAL statement_timeout = '{statement_timeout}';\n"
        f"SET LOCAL lock_timeout = '{lock_timeout}';\n"
        f"\\ir '{script.as_posix()}'\n"
        "ROLLBACK;\n"
    )


def run_script(script: Path, database: str, psql_path: str, statement_timeout: str, lock_timeout: str) -> dict[str, object]:
    started = time.monotonic()
    with tempfile.NamedTemporaryFile(mode="w", suffix=".sql", encoding="utf-8", delete=False) as driver:
        driver.write(driver_text(script, statement_timeout, lock_timeout))
        driver_path = Path(driver.name)
    try:
        completed = subprocess.run(
            [*psql_base(database, psql_path), "-f", str(driver_path)],
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
    finally:
        driver_path.unlink(missing_ok=True)
    duration_ms = round((time.monotonic() - started) * 1000)
    stderr = completed.stderr.strip()
    return {
        "script": script.relative_to(REPO_ROOT).as_posix(),
        "status": "PASS" if completed.returncode == 0 else ("TIMEOUT" if "statement timeout" in stderr else "FAIL"),
        "duration_ms": duration_ms,
        "stderr": stderr,
    }


def write_reports(report_dir: Path, metadata: dict[str, object], results: list[dict[str, object]]) -> None:
    report_dir.mkdir(parents=True, exist_ok=True)
    payload = {**metadata, "results": results}
    (report_dir / "report.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    counts = {status: sum(row["status"] == status for row in results) for status in ("PASS", "FAIL", "TIMEOUT")}
    lines = [
        "# PostgreSQL Diagnostic Validation Report",
        "",
        f"- Captured at: `{metadata['captured_at']}`",
        f"- Target: `{metadata['server']['database']}` as `{metadata['server']['user']}`",
        f"- Server: `{metadata['server']['server_version']}`",
        f"- Recovery mode: `{metadata['server']['recovery']}`",
        f"- Scripts: `{len(results)}`; pass: `{counts['PASS']}`; fail: `{counts['FAIL']}`; timeout: `{counts['TIMEOUT']}`",
        "",
        "| Status | Duration ms | Script | Error |",
        "| --- | ---: | --- | --- |",
    ]
    for row in results:
        error = str(row["stderr"]).replace("|", "\\|").replace("\n", "<br>")
        lines.append(f"| {row['status']} | {row['duration_ms']} | `{row['script']}` | {error} |")
    (report_dir / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", required=True, help="psql connection string or database name; use PG* environment variables for credentials")
    parser.add_argument("--path", help="one .sql file or folder relative to the repository")
    parser.add_argument("--include-stateful", action="store_true", help="include repository/snapshot workflows with prerequisites")
    parser.add_argument("--statement-timeout", default="60s")
    parser.add_argument("--lock-timeout", default="5s")
    parser.add_argument("--psql-path", default=os.environ.get("PSQL", "psql"))
    parser.add_argument("--report-dir", default="_validation_runs/latest")
    args = parser.parse_args()

    try:
        scripts = discover_scripts(args.path, args.include_stateful)
        if not scripts:
            raise ValueError("No scripts matched the selected scope")
        server = server_identity(args.database, args.psql_path)
    except (ValueError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"Validation setup failed: {exc}", file=sys.stderr)
        return 2

    results = [run_script(script, args.database, args.psql_path, args.statement_timeout, args.lock_timeout) for script in scripts]
    metadata = {
        "captured_at": datetime.now(timezone.utc).isoformat(),
        "repository": str(REPO_ROOT),
        "server": server,
        "transaction_mode": "BEGIN; SET LOCAL timeouts; script; ROLLBACK",
        "include_stateful": args.include_stateful,
    }
    report_dir = (REPO_ROOT / args.report_dir).resolve()
    write_reports(report_dir, metadata, results)
    passed = sum(row["status"] == "PASS" for row in results)
    print(f"Validated {len(results)} scripts: {passed} PASS, {len(results) - passed} not passing")
    print(f"Report: {report_dir / 'report.md'}")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
