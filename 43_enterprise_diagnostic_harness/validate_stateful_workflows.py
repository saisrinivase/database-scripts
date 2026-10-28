#!/usr/bin/env python3
"""Validate stateful repository workflows in a disposable PostgreSQL database only."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = {
    "capacity": [
        "15_capacity_forecasting/01_create_capacity_repository.sql",
        "15_capacity_forecasting/02_capture_database_size_snapshot.sql",
        "15_capacity_forecasting/03_capture_table_size_snapshot.sql",
        "15_capacity_forecasting/04_capture_index_size_snapshot.sql",
        "15_capacity_forecasting/05_capture_connection_snapshot.sql",
        "15_capacity_forecasting/06_capture_wal_snapshot.sql",
        "15_capacity_forecasting/07_database_growth_report.sql",
        "15_capacity_forecasting/08_table_growth_report.sql",
    ],
    "lifecycle": [
        "37_object_lifecycle_capacity/01_create_lifecycle_repository.sql",
        "37_object_lifecycle_capacity/02_create_ddl_event_triggers.sql",
        "37_object_lifecycle_capacity/03_create_snapshot_procedures.sql",
        "37_object_lifecycle_capacity/04_capture_snapshot_now.sql",
        "37_object_lifecycle_capacity/05_create_index_lifecycle_views.sql",
        "37_object_lifecycle_capacity/06_create_table_modification_views.sql",
        "37_object_lifecycle_capacity/07_create_growth_views.sql",
        "37_object_lifecycle_capacity/08_create_action_advisory_views.sql",
        "37_object_lifecycle_capacity/09_scheduler_runbook.sql",
        "37_object_lifecycle_capacity/10_monthly_capacity_report.sql",
    ],
    "observer": [
        "39_observer_agent_monitoring/01_create_observer_repository.sql",
        "39_observer_agent_monitoring/02_capture_observer_snapshot.sql",
        "39_observer_agent_monitoring/03_health_score_dashboard.sql",
        "39_observer_agent_monitoring/04_active_incident_detector.sql",
        "39_observer_agent_monitoring/05_wait_lock_io_wal_classifier.sql",
        "39_observer_agent_monitoring/06_top_root_cause_action_queue.sql",
        "39_observer_agent_monitoring/07_baseline_deviation_report.sql",
        "39_observer_agent_monitoring/08_sla_risk_dashboard.sql",
        "39_observer_agent_monitoring/09_generate_agent_summary.sql",
        "39_observer_agent_monitoring/10_observer_scheduler_runbook.sql",
    ],
}
INTENTIONALLY_EXCLUDED = {
    "37_object_lifecycle_capacity/11_index_usage_lab_create_use_drop_demo.sql",
    "37_object_lifecycle_capacity/12_table_modification_tracking_demo.sql",
}


def validate_manifest_coverage() -> None:
    stateful_areas = {"15_capacity_forecasting", "37_object_lifecycle_capacity", "39_observer_agent_monitoring"}
    discovered = {
        path.relative_to(REPO_ROOT).as_posix()
        for area in stateful_areas
        for path in (REPO_ROOT / area).glob("*.sql")
    }
    declared = {script for scripts in WORKFLOWS.values() for script in scripts}
    missing = discovered - declared - INTENTIONALLY_EXCLUDED
    stale = (declared | INTENTIONALLY_EXCLUDED) - discovered
    if missing or stale:
        raise ValueError(
            "Stateful validation manifest mismatch; "
            f"unclassified={sorted(missing)}, missing_files={sorted(stale)}"
        )


def psql_base(database: str, psql_path: str) -> list[str]:
    return [psql_path, "-X", "-v", "ON_ERROR_STOP=1", "--dbname", database]


def ensure_ephemeral(database: str, confirmation: bool) -> None:
    if not confirmation:
        raise ValueError("Pass --confirm-ephemeral after creating a disposable database")
    # Connection URLs and simple names are both allowed, but the actual database name is checked below.
    if "_ci" not in database and "_test" not in database and "_ephemeral" not in database:
        raise ValueError("--database must clearly identify a disposable target: use a name/URL containing _ci, _test, or _ephemeral")


def execute(script: str, database: str, psql_path: str) -> dict[str, object]:
    started = time.monotonic()
    result = subprocess.run(
        [*psql_base(database, psql_path), "-f", str(REPO_ROOT / script)],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    return {
        "script": script,
        "status": "PASS" if result.returncode == 0 else "FAIL",
        "duration_ms": round((time.monotonic() - started) * 1000),
        "stderr": result.stderr.strip(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", required=True, help="Disposable psql connection string or database name")
    parser.add_argument("--confirm-ephemeral", action="store_true")
    parser.add_argument("--workflow", choices=(*WORKFLOWS, "all"), default="all")
    parser.add_argument("--psql-path", default=os.environ.get("PSQL", "psql"))
    parser.add_argument("--report", default="_validation_runs/stateful-report.json")
    args = parser.parse_args()

    try:
        ensure_ephemeral(args.database, args.confirm_ephemeral)
        validate_manifest_coverage()
    except ValueError as exc:
        print(f"Safety check failed: {exc}", file=sys.stderr)
        return 2
    selected = WORKFLOWS if args.workflow == "all" else {args.workflow: WORKFLOWS[args.workflow]}
    results = [execute(script, args.database, args.psql_path) for scripts in selected.values() for script in scripts]
    report = {
        "captured_at": datetime.now(timezone.utc).isoformat(),
        "database": args.database,
        "workflow": args.workflow,
        "results": results,
    }
    report_path = (REPO_ROOT / args.report).resolve()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    passed = sum(result["status"] == "PASS" for result in results)
    print(f"Validated {len(results)} stateful workflow scripts: {passed} PASS, {len(results) - passed} FAIL")
    print(f"Report: {report_path}")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
