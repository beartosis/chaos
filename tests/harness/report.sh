#!/bin/bash
# Generate summary reports from eval results
# Usage: ./report.sh [results-dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="${1:-$TESTS_DIR/results}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================="
echo "CHAOS Agent Evaluation Report"
echo "=================================="
echo ""

# Find all summary files
summaries=$(find "$RESULTS_DIR" -name "summary.json" -type f 2>/dev/null | sort -r)

if [[ -z "$summaries" ]]; then
    echo "No evaluation results found in $RESULTS_DIR"
    exit 0
fi

# Print summary for each run
for summary in $summaries; do
    run_dir=$(dirname "$summary")
    run_name=$(basename "$run_dir")

    echo "Run: $run_name"
    echo "---"

    if command -v jq &> /dev/null; then
        # Pretty print with jq if available
        jq '.' "$summary"
    else
        # Fallback to cat
        cat "$summary"
    fi

    echo ""
done

# Aggregate statistics (if multiple runs exist)
total_runs=$(echo "$summaries" | wc -l)
echo "=================================="
echo "Total runs found: $total_runs"
echo "=================================="
