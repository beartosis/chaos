#!/bin/bash
# Environment isolation helpers for CHAOS skill evals
# Provides clean, isolated environments for each trial run

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create an isolated working directory for a trial
# Usage: workdir=$(create_isolated_env "simple-crud")
create_isolated_env() {
    local codebase="$1"
    local source_dir="$TESTS_DIR/fixtures/codebases/$codebase"

    if [[ ! -d "$source_dir" ]]; then
        echo "ERROR: Codebase not found: $source_dir" >&2
        return 1
    fi

    # Create temp directory with unique name
    local workdir=$(mktemp -d -t "chaos-eval-XXXXXX")

    # Copy codebase to isolated environment
    cp -r "$source_dir"/* "$workdir/"

    # Set up minimal CHAOS structure for skill testing
    mkdir -p "$workdir/.chaos"
    echo "# Project Learnings" > "$workdir/.chaos/learnings.md"
    mkdir -p "$workdir/.chaos/framework"
    echo "CHAOS_VERSION=2.0.0" > "$workdir/.chaos/framework/version"

    echo "$workdir"
}

# Clean up an isolated environment
# Usage: cleanup_isolated_env "$workdir"
cleanup_isolated_env() {
    local workdir="$1"

    # Match chaos-eval- anywhere in path (handles /tmp, /var/folders, etc.)
    if [[ -d "$workdir" ]] && [[ "$workdir" == *chaos-eval-* ]]; then
        rm -rf "$workdir"
    else
        echo "WARN: Refusing to clean up suspicious directory: $workdir" >&2
    fi
}

# Run a skill in isolation with timeout
# Usage: run_isolated_skill "self-check" "input.md" "$workdir" 300
run_isolated_skill() {
    local skill="$1"
    local input="$2"
    local workdir="$3"
    local timeout_sec="${4:-300}"
    local mock="${5:-false}"

    local output_file="$workdir/skill_output.txt"
    local exit_code_file="$workdir/exit_code.txt"

    # Read the input file content
    local input_content=""
    if [[ -f "$input" ]]; then
        input_content=$(cat "$input")
    else
        input_content="$input"
    fi

    if [[ "$mock" == "true" ]]; then
        # Mock mode - don't call CLI, return valid output
        cat > "$output_file" <<'MOCK_EOF'
READY TO PUSH

All checks passed:
- Tests pass
- No hardcoded values
- Follows existing patterns
- Changes scoped to task
MOCK_EOF
        echo "0" > "$exit_code_file"
    else
        # Build prompt for skill evaluation
        local prompt="You are running the /$skill skill.

## Input:

$input_content

## Instructions:

Execute the skill and produce the expected output format."

        # Run Claude Code CLI in print mode
        (
            cd "$workdir"
            timeout "$timeout_sec" claude -p "$prompt" --model haiku 2>&1 | tee "$output_file"
            echo "${PIPESTATUS[0]}" > "$exit_code_file"
        )
    fi

    cat "$output_file"
}

# Run multiple trials for a single task
# Usage: run_trials "self-check" "input.md" "simple-crud" 3
run_trials() {
    local skill="$1"
    local input="$2"
    local codebase="$3"
    local num_trials="$4"

    local passes=0

    for i in $(seq 1 "$num_trials"); do
        local workdir=$(create_isolated_env "$codebase")

        if run_isolated_skill "$skill" "$input" "$workdir"; then
            ((passes++)) || true
        fi

        cleanup_isolated_env "$workdir"
    done

    # Calculate metrics
    local pass_at_k=0
    local pass_power_k=0

    if (( passes > 0 )); then
        pass_at_k=1
    fi

    if (( passes == num_trials )); then
        pass_power_k=1
    fi

    echo "passes=$passes pass_at_k=$pass_at_k pass_power_k=$pass_power_k"
}
