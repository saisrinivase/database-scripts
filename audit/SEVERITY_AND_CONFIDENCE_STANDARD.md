# Severity, filter, and diagnostic-confidence standard

Severity is an operational prioritization label, not proof of root cause. Every
`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, `WARN`, `REVIEW`, or `OK` result must be
interpretable using the following fields:

| Field | Required meaning |
| --- | --- |
| Metric | The value actually measured or observed |
| Unit | Bytes, percent, milliseconds, count, age, ratio, or state |
| Filter | Which objects, sessions, statements, or time range were included |
| Threshold | The exact condition that selected the severity |
| Window | Instantaneous, since reset, sampled interval, or repository range |
| Evidence | Catalog fact, live snapshot, cumulative counter, estimate, history, or external metric |
| Rule confidence | Confidence that the SQL evaluated the documented rule correctly |
| Root-cause confidence | Confidence that this evidence alone identifies the cause |
| Next confirmation | Independent evidence required before remediation |

## Standard severity semantics

| Label | Meaning | Expected response |
| --- | --- | --- |
| `CRITICAL` | An explicit threshold indicates immediate availability, data-protection, wraparound, corruption, or severe saturation risk | Validate the evidence immediately and follow the incident/runbook path |
| `HIGH` | Strong threshold breach with material performance, capacity, security, or recoverability impact | Investigate promptly and correlate the same time window |
| `MEDIUM` / `WARN` | Deviation or developing pressure that may be workload-dependent | Compare with baseline, trend, and related subsystem evidence |
| `LOW` / `REVIEW` | Weak signal, hygiene issue, candidate, or incomplete evidence | Review during normal tuning or maintenance work |
| `OK` | No configured rule breached in the observed scope/window | Not proof that the subsystem is healthy outside that scope/window |

## Confidence semantics

`rule_evaluation_confidence` answers: “Did the query reliably evaluate its
documented rule?” It does not answer: “Is this threshold correct for every
system?”

- `HIGH`: explicit rule over current catalog/configuration or live-state facts.
- `MEDIUM`: explicit rule over cumulative, sampled, estimated, or repository
  evidence; reset/window/cadence can change the interpretation.
- `LOW`: advisory wording, mechanically untraceable criteria, provider/external
  dependency, or insufficient evidence.

`root_cause_confidence` is deliberately conservative. A severity rule alone is
never assigned `HIGH`. Root cause normally requires correlation across SQL,
waits, execution plans, logs, OS/cloud telemetry, and a matching time window.

## Threshold policy

Hard-coded thresholds are starting guardrails, not universal truths. Before
production use:

1. Capture at least one representative business cycle and peak period.
2. Define service objectives, capacity headroom, RPO/RTO, and escalation policy.
3. Use interval deltas for cumulative counters and record reset timestamps.
4. Replace generic thresholds with approved `pgdiag.*` overrides where the
   script supports them, or maintain a reviewed environment profile.
5. Require two independent signals before destructive, scaling, parameter, or
   index-removal action unless the signal is an exact integrity failure.

The generated `severity-filter-confidence-registry.tsv` provides one row per SQL
script with active severity/advisory keywords, configurable settings, extracted CASE conditions, row
filters, evidence type, both confidence levels, and interpretation limits.

The registry is intentionally transparent about review status. Mechanical
extraction proves inventory coverage, not that every generic threshold is
appropriate for a particular production workload. Only rows marked
`MANUALLY_VERIFIED_AND_RUNTIME_TESTED` have completed both semantic and runtime
threshold review; `MECHANICALLY_EXTRACTED_REVIEW_REQUIRED` rows must be baselined
and approved before alerting or automated action.
