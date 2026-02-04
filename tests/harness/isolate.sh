#!/bin/bash
# Environment isolation helpers for CHAOS agent evals
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

# Run an agent in isolation with timeout
# Usage: run_isolated_agent "spec-reviewer" "input.md" "$workdir" 300
run_isolated_agent() {
    local agent="$1"
    local input="$2"
    local workdir="$3"
    local timeout_sec="${4:-300}"
    local mock="${5:-false}"

    local output_file="$workdir/agent_output.txt"
    local exit_code_file="$workdir/exit_code.txt"

    # Get the agent prompt from CHAOS agents directory
    local agent_file="$TESTS_DIR/../templates/.claude/agents/${agent}.md.tmpl"
    if [[ ! -f "$agent_file" ]]; then
        # Try without .tmpl extension
        agent_file="$TESTS_DIR/../templates/.claude/agents/${agent}.md"
    fi

    # Read the input file content
    local input_content=""
    if [[ -f "$input" ]]; then
        input_content=$(cat "$input")
    else
        input_content="$input"
    fi

    if [[ "$mock" == "true" ]]; then
        # Mock mode - don't call CLI, return valid JSON
        cat > "$output_file" <<'MOCK_EOF'
```json
{
  "status": "APPROVED",
  "score": 0.85,
  "summary": "Mock evaluation - spec appears complete",
  "issues": []
}
```
MOCK_EOF
        echo "0" > "$exit_code_file"
    else
        # Build prompt that requests structured JSON output
        local prompt="You are evaluating a software specification for completeness.

## Specification to Review:

$input_content

## Evaluation Criteria:

A complete spec must have:
1. Clear, specific goal (not vague)
2. Actionable requirements (not abstract like 'improve things')
3. Concrete acceptance criteria (testable, not 'users are happy')
4. Defined constraints
5. Clear scope boundaries

## Required Output Format:

You MUST respond with ONLY a JSON object (no other text):

\`\`\`json
{
  \"status\": \"APPROVED\" or \"NEEDS_WORK\",
  \"score\": 0.0 to 1.0,
  \"summary\": \"one sentence summary\",
  \"issues\": [\"issue 1\", \"issue 2\"] or []
}
\`\`\`

Evaluate the spec and return ONLY the JSON."

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
# Usage: run_trials "spec-reviewer" "input.md" "simple-crud" 3
run_trials() {
    local agent="$1"
    local input="$2"
    local codebase="$3"
    local num_trials="$4"

    local passes=0

    for i in $(seq 1 "$num_trials"); do
        local workdir=$(create_isolated_env "$codebase")

        if run_isolated_agent "$agent" "$input" "$workdir"; then
            # Grade the output (placeholder - would use graders)
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
