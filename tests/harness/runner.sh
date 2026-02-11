#!/bin/bash
# CHAOS Skill Evaluation Runner
# Usage: ./runner.sh <skill> <eval-type> [--trials N] [--mock]
#
# Uses Claude Code CLI for skill execution and LLM-based grading.
# No API key required - uses existing Claude Code subscription.
#
# Examples:
#   ./runner.sh self-check capability           # Real evaluation
#   ./runner.sh self-check capability --mock    # Test harness only
#   ./runner.sh learn capability --trials 5

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$TESTS_DIR/results"

# Defaults
TRIALS=3
SKILL=""
EVAL_TYPE=""
MOCK_MODE="false"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <skill> <eval-type> [--trials N] [--mock]"
    echo ""
    echo "Arguments:"
    echo "  skill      Skill to evaluate (self-check, learn, work, review-feedback)"
    echo "  eval-type  Type of evaluation (capability, regression, structural)"
    echo ""
    echo "Options:"
    echo "  --trials N   Number of trials per task (default: 3)"
    echo "  --mock       Run in mock mode (no actual CLI calls)"
    echo ""
    echo "Examples:"
    echo "  $0 self-check capability           # Full evaluation with Claude CLI"
    echo "  $0 self-check capability --mock    # Test the harness without CLI calls"
    echo "  $0 learn capability --trials 5"
    exit 1
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_task() {
    echo -e "${BLUE}[TASK]${NC} $1"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --trials)
            TRIALS="$2"
            shift 2
            ;;
        --mock)
            MOCK_MODE="true"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$SKILL" ]]; then
                SKILL="$1"
            elif [[ -z "$EVAL_TYPE" ]]; then
                EVAL_TYPE="$1"
            else
                log_error "Unknown argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$SKILL" ]] || [[ -z "$EVAL_TYPE" ]]; then
    log_error "Missing required arguments"
    usage
fi

EVAL_FILE="$TESTS_DIR/evals/$EVAL_TYPE/$SKILL.yml"
if [[ ! -f "$EVAL_FILE" ]]; then
    log_error "Eval file not found: $EVAL_FILE"
    exit 1
fi

# Create results directory
RUN_ID=$(date +%Y%m%d-%H%M%S)
RUN_DIR="$RESULTS_DIR/$SKILL-$EVAL_TYPE-$RUN_ID"
mkdir -p "$RUN_DIR"

log_info "Starting evaluation run: $RUN_ID"
log_info "Skill: $SKILL"
log_info "Eval type: $EVAL_TYPE"
log_info "Trials per task: $TRIALS"
log_info "Mock mode: $MOCK_MODE"
log_info "Results: $RUN_DIR"
echo ""

# Source isolation helpers
source "$SCRIPT_DIR/isolate.sh"

# Export MOCK_MODE for use in isolate.sh
export MOCK_MODE

# Run a single task and grade it
run_single_task() {
    local task_id="$1"
    local input_file="$2"
    local expected_status="$3"
    local task_type="$4"  # positive or negative

    local task_dir="$RUN_DIR/tasks/$task_id"
    mkdir -p "$task_dir"

    local passes=0

    for trial in $(seq 1 "$TRIALS"); do
        log_task "  Trial $trial/$TRIALS for $task_id" >&2

        # Create isolated environment
        local workdir=$(create_isolated_env "simple-crud" 2>/dev/null || echo "/tmp/chaos-eval-$$-$trial")
        mkdir -p "$workdir"

        # Run skill
        local output
        output=$(run_isolated_skill "$SKILL" "$TESTS_DIR/$input_file" "$workdir" 120 "$MOCK_MODE" 2>&1)

        # Save output
        echo "$output" > "$task_dir/trial_${trial}_output.txt"

        # Grade the output - parse JSON response
        local actual_status="UNKNOWN"
        local parse_method="unknown"

        # Extract JSON from response (may be wrapped in ```json ... ```)
        local json_content
        json_content=$(echo "$output" | sed -n '/```json/,/```/p' | sed '1d;$d')

        # If no ```json block, try to find raw JSON
        if [[ -z "$json_content" ]]; then
            json_content=$(echo "$output" | grep -o '{[^}]*"status"[^}]*}' | head -1)
        fi

        # Try to parse status from JSON
        if [[ -n "$json_content" ]] && command -v jq &> /dev/null; then
            local parsed_status
            parsed_status=$(echo "$json_content" | jq -r '.status // empty' 2>/dev/null)
            if [[ "$parsed_status" == "APPROVED" || "$parsed_status" == "NEEDS_WORK" || "$parsed_status" == "READY_TO_PUSH" || "$parsed_status" == "NEEDS_FIXES" ]]; then
                actual_status="$parsed_status"
                parse_method="json"
            fi
        fi

        # Fallback: use LLM-as-judge to interpret the response
        if [[ "$actual_status" == "UNKNOWN" && "$MOCK_MODE" != "true" ]]; then
            parse_method="llm-judge"
            local judge_prompt="Read this output and answer with ONLY one word - either PASS or FAIL:

$output

Answer (one word only):"

            local judge_response
            judge_response=$(timeout 30 claude -p "$judge_prompt" --model haiku 2>/dev/null | tr -d '[:space:]')

            if [[ "$judge_response" == *"PASS"* ]]; then
                actual_status="PASS"
            elif [[ "$judge_response" == *"FAIL"* ]]; then
                actual_status="FAIL"
            fi
        fi

        # Log parse method for debugging
        echo "parse_method=$parse_method" >> "$task_dir/trial_${trial}_meta.txt"

        # Determine pass/fail based on task type
        local trial_pass=0
        if [[ "$task_type" == "positive" ]]; then
            if [[ "$actual_status" == "$expected_status" ]]; then
                trial_pass=1
            fi
        else
            local forbidden_status
            if [[ "$expected_status" == "PASS" ]]; then
                forbidden_status="FAIL"
            else
                forbidden_status="PASS"
            fi
            if [[ "$actual_status" != "$forbidden_status" ]]; then
                trial_pass=1
            fi
        fi

        if [[ $trial_pass -eq 1 ]]; then
            ((passes++)) || true
            echo "PASS" > "$task_dir/trial_${trial}_result.txt"
        else
            echo "FAIL (expected: $expected_status, got: $actual_status)" > "$task_dir/trial_${trial}_result.txt"
        fi

        # Cleanup
        cleanup_isolated_env "$workdir" 2>/dev/null || true
    done

    # Return results
    echo "$passes"
}

# Parse eval file and run tasks
run_eval() {
    local eval_file="$1"
    local tasks_run=0
    local total_passes=0
    local pass_at_k_count=0
    local pass_power_k_count=0
    local failures=()

    log_info "Loading tasks from $eval_file"

    # Simple YAML parsing
    local task_ids=()
    local task_inputs=()
    local task_expected=()
    local task_types=()

    local current_id=""
    local current_input=""
    local current_type="positive"

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*id:[[:space:]]*(.+)$ ]]; then
            current_id="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*type:[[:space:]]*(.+)$ ]]; then
            current_type="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*spec:[[:space:]]*(.+)$ ]]; then
            current_input="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*input:[[:space:]]*(.+)$ ]]; then
            current_input="${BASH_REMATCH[1]}"
        fi

        if [[ -n "$current_id" && -n "$current_input" ]]; then
            task_ids+=("$current_id")
            task_inputs+=("$current_input")
            task_types+=("$current_type")

            if [[ "$current_input" == *"/complete/"* ]] || [[ "$current_input" == *"/pass/"* ]]; then
                task_expected+=("PASS")
            else
                task_expected+=("FAIL")
            fi

            current_id=""
            current_input=""
            current_type="positive"
        fi
    done < "$eval_file"

    log_info "Found ${#task_ids[@]} tasks to run"
    echo ""

    for i in "${!task_ids[@]}"; do
        local task_id="${task_ids[$i]}"
        local input="${task_inputs[$i]}"
        local expected="${task_expected[$i]}"
        local task_type="${task_types[$i]}"

        log_task "Running task: $task_id ($task_type)"

        local passes
        passes=$(run_single_task "$task_id" "$input" "$expected" "$task_type")

        ((tasks_run++)) || true
        ((total_passes += passes)) || true

        if [[ $passes -gt 0 ]]; then
            ((pass_at_k_count++)) || true
        fi
        if [[ $passes -eq $TRIALS ]]; then
            ((pass_power_k_count++)) || true
        fi

        echo "    Result: $passes/$TRIALS trials passed"
    done

    echo ""

    local pass_at_k_pct=0
    local pass_power_k_pct=0
    if [[ $tasks_run -gt 0 ]]; then
        pass_at_k_pct=$(( (pass_at_k_count * 100) / tasks_run ))
        pass_power_k_pct=$(( (pass_power_k_count * 100) / tasks_run ))
    fi

    cat > "$RUN_DIR/summary.json" <<EOF
{
  "run_id": "$RUN_ID",
  "skill": "$SKILL",
  "eval_type": "$EVAL_TYPE",
  "mock_mode": $MOCK_MODE,
  "trials_per_task": $TRIALS,
  "tasks_run": $tasks_run,
  "pass_at_${TRIALS}_pct": $pass_at_k_pct,
  "pass_at_${TRIALS}_count": $pass_at_k_count,
  "pass_power_${TRIALS}_pct": $pass_power_k_pct,
  "pass_power_${TRIALS}_count": $pass_power_k_count,
  "timestamp": "$(date -Iseconds)"
}
EOF

    log_info "Summary written to $RUN_DIR/summary.json"

    echo ""
    echo "=================================="
    echo "EVALUATION SUMMARY"
    echo "=================================="
    echo "Tasks run:       $tasks_run"
    echo "Pass@$TRIALS:         ${pass_at_k_pct}% ($pass_at_k_count/$tasks_run)"
    echo "Pass^$TRIALS:         ${pass_power_k_pct}% ($pass_power_k_count/$tasks_run)"
    echo "=================================="
}

# Main execution
run_eval "$EVAL_FILE"

log_info "Evaluation complete!"
echo ""
echo "Full results: $RUN_DIR/"
