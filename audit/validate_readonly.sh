#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 DATABASE OUTPUT_DIRECTORY" >&2
  exit 2
fi

audit_database=$1
audit_output_directory=$2
repository_root=$(cd "$(dirname "$0")/.." && pwd)
audit_role=${AUDIT_ROLE:-}

mkdir -p "$audit_output_directory/logs"
report_file="$audit_output_directory/readonly-results.tsv"
printf 'script\tresult\tduration_ms\terror\n' > "$report_file"

while IFS= read -r script_path; do
  relative_path=${script_path#"$repository_root"/}
  safe_name=${relative_path//\//__}
  log_file="$audit_output_directory/logs/${safe_name}.log"
  start_ns=$(date +%s%N)

  set +e
  {
    printf '%s\n' "BEGIN READ ONLY;"
    printf '%s\n' "SET LOCAL statement_timeout = '15s';"
    printf '%s\n' "SET LOCAL lock_timeout = '1s';"
    printf '%s\n' "SET LOCAL idle_in_transaction_session_timeout = '30s';"
    printf '%s\n' "SET LOCAL temp_file_limit = '128MB';"
    if [[ -n "$audit_role" ]]; then
      printf 'SET ROLE %s;\n' "$audit_role"
    fi
    printf '\\i %s\n' "$script_path"
    printf '%s\n' "ROLLBACK;"
  } | psql -X -v ON_ERROR_STOP=1 -q -d "$audit_database" >"$log_file" 2>&1
  exit_code=$?
  set -e

  end_ns=$(date +%s%N)
  duration_ms=$(( (end_ns - start_ns) / 1000000 ))
  if [[ $exit_code -eq 0 ]]; then
    result=PASS
    error='-'
  else
    result=FAIL
    error=$(tail -n 4 "$log_file" | tr '\t\n' '  ' | sed 's/[[:space:]][[:space:]]*/ /g')
  fi
  printf '%s\t%s\t%s\t%s\n' "$relative_path" "$result" "$duration_ms" "$error" >> "$report_file"
done < <(find "$repository_root" -mindepth 2 -type f -name '*.sql' -not -path "$repository_root/audit/*" | sort)

awk -F '\t' 'NR > 1 { count[$2]++ } END { for (result in count) print result, count[result] }' "$report_file" | sort
