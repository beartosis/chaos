#!/bin/bash
# Code-based graders for CHAOS skill output validation
# These provide fast, deterministic checks

set -euo pipefail

# Check if output contains required summary structure
# Usage: check_summary_format "output.txt"
check_summary_format() {
    local output_file="$1"

    if [[ ! -f "$output_file" ]]; then
        echo "FAIL: Output file not found"
        return 1
    fi

    local content=$(cat "$output_file")

    # Check for summary section
    if ! echo "$content" | grep -q "## Summary\|### CRITICAL"; then
        echo "FAIL: Missing summary section"
        return 1
    fi

    # Check for status indicator
    if ! echo "$content" | grep -q "\*\*Status\*\*:"; then
        echo "FAIL: Missing status indicator"
        return 1
    fi

    echo "PASS: Summary format valid"
    return 0
}

# Check spec-reviewer status output
# Usage: check_status "output.txt" "APPROVED"
check_status() {
    local output_file="$1"
    local expected_status="$2"

    local content=$(cat "$output_file")

    # Extract status from output
    local actual_status=$(echo "$content" | grep -oP '\*\*Status\*\*:\s*\K\w+' | head -1)

    if [[ "$actual_status" == "$expected_status" ]]; then
        echo "PASS: Status is $expected_status"
        return 0
    else
        echo "FAIL: Expected status '$expected_status', got '$actual_status'"
        return 1
    fi
}

# Check that feedback is provided
# Usage: check_has_feedback "output.txt" 50
check_has_feedback() {
    local output_file="$1"
    local min_length="${2:-10}"

    local content=$(cat "$output_file")

    # Look for feedback section
    local feedback=$(echo "$content" | grep -A 10 "Feedback\|Issues\|Missing" | head -20)

    if [[ ${#feedback} -ge $min_length ]]; then
        echo "PASS: Feedback provided (${#feedback} chars)"
        return 0
    else
        echo "FAIL: Insufficient feedback (${#feedback} < $min_length chars)"
        return 1
    fi
}

# Check completeness score
# Usage: check_completeness_score "output.txt" 0.8
check_completeness_score() {
    local output_file="$1"
    local min_score="$2"

    local content=$(cat "$output_file")

    # Extract score (various formats: 0.85, 85%, 85/100)
    local score=$(echo "$content" | grep -oP '(?:completeness|score)[:\s]*\K[\d.]+' | head -1)

    if [[ -z "$score" ]]; then
        echo "WARN: Could not extract completeness score"
        return 0  # Don't fail if score format not found
    fi

    # Normalize to integer percentage (0-100 scale) for comparison
    # Handle both "85" and "0.85" formats
    local score_int
    if [[ "$score" == 0.* ]]; then
        # Decimal like 0.85 -> 85
        score_int="${score#0.}"
        score_int="${score_int:0:2}"  # Take first 2 digits
    elif [[ "$score" == *.* ]]; then
        # Decimal like 85.5 -> 85 (truncate)
        score_int="${score%%.*}"
    else
        # Already integer like 85
        score_int="$score"
    fi

    # Convert min_score the same way
    local min_int
    if [[ "$min_score" == 0.* ]]; then
        min_int="${min_score#0.}"
        min_int="${min_int:0:2}"
    elif [[ "$min_score" == *.* ]]; then
        min_int="${min_score%%.*}"
    else
        min_int="$min_score"
    fi

    if (( score_int >= min_int )); then
        echo "PASS: Score $score >= $min_score"
        return 0
    else
        echo "FAIL: Score $score < $min_score"
        return 1
    fi
}

# Check that output mentions specific term
# Usage: check_mentions "output.txt" "acceptance criteria"
check_mentions() {
    local output_file="$1"
    local term="$2"

    if grep -qi "$term" "$output_file"; then
        echo "PASS: Output mentions '$term'"
        return 0
    else
        echo "FAIL: Output does not mention '$term'"
        return 1
    fi
}

# Check Beads command syntax
# Usage: check_beads_commands "output.txt"
check_beads_commands() {
    local output_file="$1"

    local content=$(cat "$output_file")

    # Find all bd commands
    local commands=$(echo "$content" | grep -oE "bd (update|create|close|show)[^|&;\n]+" || true)

    if [[ -z "$commands" ]]; then
        echo "PASS: No Beads commands to validate"
        return 0
    fi

    # Validate each command structure (basic syntax check)
    local errors=0
    while IFS= read -r cmd; do
        # Check for required issue ID in update/close/show commands
        if echo "$cmd" | grep -qE "^bd (update|close|show)" && ! echo "$cmd" | grep -qE "\S+$"; then
            echo "WARN: Possibly malformed command: $cmd"
            ((errors++)) || true
        fi
    done <<< "$commands"

    if [[ $errors -eq 0 ]]; then
        echo "PASS: Beads commands valid"
        return 0
    else
        echo "WARN: $errors potential issues with Beads commands"
        return 0  # Warn but don't fail
    fi
}

# Main dispatch for running specific checks
# Usage: ./structure.sh <check_name> <output_file> [args...]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_name="${1:-}"
    shift || true

    case "$check_name" in
        summary_format)
            check_summary_format "$@"
            ;;
        status)
            check_status "$@"
            ;;
        has_feedback)
            check_has_feedback "$@"
            ;;
        completeness_score)
            check_completeness_score "$@"
            ;;
        mentions)
            check_mentions "$@"
            ;;
        beads_commands)
            check_beads_commands "$@"
            ;;
        *)
            echo "Unknown check: $check_name"
            echo "Available: summary_format, status, has_feedback, completeness_score, mentions, beads_commands"
            exit 1
            ;;
    esac
fi
