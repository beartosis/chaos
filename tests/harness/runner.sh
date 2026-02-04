#!/bin/bash
# CHAOS Agent Evaluation Runner
# Usage: ./runner.sh <agent> <eval-type> [--trials N] [--mock]
#
# Uses Claude Code CLI for agent execution and LLM-based grading.
# No API key required - uses existing Claude Code subscription.
#
# Examples:
#   ./runner.sh spec-reviewer capability           # Real evaluation
#   ./runner.sh spec-reviewer capability --mock    # Test harness only
#   ./runner.sh explore capability --trials 5

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$TESTS_DIR/results"

# Defaults
TRIALS=3
AGENT=""
EVAL_TYPE=""
MOCK_MODE="false"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <agent> <eval-type> [--trials N] [--mock]"
    echo ""
    echo "Arguments:"
    echo "  agent      Agent to evaluate (spec-reviewer, explore, plan, implement, verifier, code-reviewer)"
    echo "  eval-type  Type of evaluation (capability, regression)"
    echo ""
    echo "Options:"
    echo "  --trials N   Number of trials per task (default: 3)"
    echo "  --mock       Run in mock mode (no actual CLI calls)"
    echo ""
    echo "Examples:"
    echo "  $0 spec-reviewer capability           # Full evaluation with Claude CLI"
    echo "  $0 spec-reviewer capability --mock    # Test the harness without CLI calls"
    echo "  $0 explore capability --trials 5"
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
            if [[ -z "$AGENT" ]]; then
                AGENT="$1"
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
if [[ -z "$AGENT" ]] || [[ -z "$EVAL_TYPE" ]]; then
    log_error "Missing required arguments"
    usage
fi

EVAL_FILE="$TESTS_DIR/evals/$EVAL_TYPE/$AGENT.yml"
if [[ ! -f "$EVAL_FILE" ]]; then
    log_error "Eval file not found: $EVAL_FILE"
    exit 1
fi

# Create results directory
RUN_ID=$(date +%Y%m%d-%H%M%S)
RUN_DIR="$RESULTS_DIR/$AGENT-$EVAL_TYPE-$RUN_ID"
mkdir -p "$RUN_DIR"

log_info "Starting evaluation run: $RUN_ID"
log_info "Agent: $AGENT"
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

        # Run agent
        local output
        output=$(run_isolated_agent "$AGENT" "$TESTS_DIR/$input_file" "$workdir" 120 "$MOCK_MODE" 2>&1)

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
            if [[ "$parsed_status" == "APPROVED" || "$parsed_status" == "NEEDS_WORK" ]]; then
                actual_status="$parsed_status"
                parse_method="json"
            fi
        fi

        # Fallback: use LLM-as-judge to interpret the response
        if [[ "$actual_status" == "UNKNOWN" && "$MOCK_MODE" != "true" ]]; then
            parse_method="llm-judge"
            local judge_prompt="Read this spec review and answer with ONLY one word - either APPROVED or NEEDS_WORK:

$output

Answer (one word only):"

            local judge_response
            judge_response=$(timeout 30 claude -p "$judge_prompt" --model haiku 2>/dev/null | tr -d '[:space:]')

            if [[ "$judge_response" == *"APPROVED"* ]]; then
                actual_status="APPROVED"
            elif [[ "$judge_response" == *"NEEDS_WORK"* ]]; then
                actual_status="NEEDS_WORK"
            fi
        fi

        # Log parse method for debugging
        echo "parse_method=$parse_method" >> "$task_dir/trial_${trial}_meta.txt"

        # Determine pass/fail based on task type
        local trial_pass=0
        if [[ "$task_type" == "positive" ]]; then
            # Positive test: expected status should match
            if [[ "$actual_status" == "$expected_status" ]]; then
                trial_pass=1
            fi
        else
            # Negative test: should NOT have forbidden status
            # For /complete/ specs, forbidden = NEEDS_WORK (no false positive rejection)
            # For /incomplete/ specs, forbidden = APPROVED (no false negative approval)
            local forbidden_status
            if [[ "$expected_status" == "APPROVED" ]]; then
                forbidden_status="NEEDS_WORK"
            else
                forbidden_status="APPROVED"
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
    local false_positives=0
    local false_negatives=0
    local failures=()

    log_info "Loading tasks from $eval_file"

    # Simple YAML parsing (for demo - production would use yq)
    # Extract task IDs and inputs from the eval file
    local task_ids=()
    local task_inputs=()
    local task_expected=()
    local task_types=()

    # Parse tasks using grep/sed (simplified - works for our format)
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

        # When we hit a new task (or end), save the previous one
        if [[ -n "$current_id" && -n "$current_input" ]]; then
            task_ids+=("$current_id")
            task_inputs+=("$current_input")
            task_types+=("$current_type")

            # Determine expected status based on input path
            if [[ "$current_input" == *"/complete/"* ]]; then
                task_expected+=("APPROVED")
            else
                task_expected+=("NEEDS_WORK")
            fi

            current_id=""
            current_input=""
            current_type="positive"
        fi
    done < "$eval_file"

    log_info "Found ${#task_ids[@]} tasks to run"
    echo ""

    # Run each task
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

        # Calculate pass@k and pass^k
        if [[ $passes -gt 0 ]]; then
            ((pass_at_k_count++)) || true
        fi
        if [[ $passes -eq $TRIALS ]]; then
            ((pass_power_k_count++)) || true
        fi

        # Track false positives/negatives for negative tests
        if [[ "$task_type" == "negative" && $passes -lt $TRIALS ]]; then
            if [[ "$expected" == "APPROVED" ]]; then
                ((false_negatives++)) || true
            else
                ((false_positives++)) || true
            fi
        fi

        echo "    Result: $passes/$TRIALS trials passed"
    done

    echo ""

    # Calculate rates
    local pass_at_k_rate=0
    local pass_power_k_rate=0
    if [[ $tasks_run -gt 0 ]]; then
        pass_at_k_rate=$(echo "scale=2; $pass_at_k_count / $tasks_run" | bc)
        pass_power_k_rate=$(echo "scale=2; $pass_power_k_count / $tasks_run" | bc)
    fi

    # Generate summary report
    cat > "$RUN_DIR/summary.json" <<EOF
{
  "run_id": "$RUN_ID",
  "agent": "$AGENT",
  "eval_type": "$EVAL_TYPE",
  "mock_mode": $MOCK_MODE,
  "trials_per_task": $TRIALS,
  "tasks_run": $tasks_run,
  "pass_at_${TRIALS}": $pass_at_k_rate,
  "pass_at_${TRIALS}_count": $pass_at_k_count,
  "pass_power_${TRIALS}": $pass_power_k_rate,
  "pass_power_${TRIALS}_count": $pass_power_k_count,
  "false_positives": $false_positives,
  "false_negatives": $false_negatives,
  "timestamp": "$(date -Iseconds)"
}
EOF

    log_info "Summary written to $RUN_DIR/summary.json"

    # Print summary
    echo ""
    echo "=================================="
    echo "EVALUATION SUMMARY"
    echo "=================================="
    echo "Tasks run:      $tasks_run"
    echo "Pass@$TRIALS:        $pass_at_k_rate ($pass_at_k_count/$tasks_run)"
    echo "Pass^$TRIALS:        $pass_power_k_rate ($pass_power_k_count/$tasks_run)"
    echo "False positives: $false_positives"
    echo "False negatives: $false_negatives"
    echo "=================================="
}

# Main execution
run_eval "$EVAL_FILE"

log_info "Evaluation complete!"
echo ""
echo "Full results: $RUN_DIR/"
