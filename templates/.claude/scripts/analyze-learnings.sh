#!/bin/bash
# CHAOS v2 — Analyze learnings for promotion candidates
#
# Usage: bash .claude/scripts/analyze-learnings.sh
#
# Scans .chaos/learnings.md for keyword frequency and repeated
# recommendation patterns. Outputs promotion candidates with
# occurrence counts. Patterns appearing 3+ times are candidates.

set -euo pipefail

LEARNINGS=".chaos/learnings.md"

if [[ ! -f "$LEARNINGS" ]]; then
    echo "No learnings file found at $LEARNINGS"
    exit 1
fi

echo "=== CHAOS: Analyze Learnings ==="
echo ""

# --- Count observations ---
OBS_COUNT=$(grep -c '^\- \*\*Observation\*\*' "$LEARNINGS" 2>/dev/null || echo "0")
PROMOTED_COUNT=$(grep -c '\[PROMOTED\]' "$LEARNINGS" 2>/dev/null || echo "0")
UNPROMOTED=$((OBS_COUNT - PROMOTED_COUNT))

echo "Total observations: $OBS_COUNT"
echo "Already promoted:   $PROMOTED_COUNT"
echo "Unpromoted:         $UNPROMOTED"
echo ""

if [[ "$UNPROMOTED" -lt 3 ]]; then
    echo "Not enough unpromoted observations for pattern detection (need 3+)."
    exit 0
fi

# --- Extract recommendation keywords ---
echo "## Recommendation Keywords (frequency >= 2)"
echo ""

# Extract recommendation lines, normalize, count frequency
grep '^\- \*\*Recommendation\*\*' "$LEARNINGS" \
    | grep -v '\[PROMOTED\]' \
    | sed 's/.*Recommendation\*\*:\s*//' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -s ' ' '\n' \
    | grep -E '^[a-z]{4,}' \
    | sort | uniq -c | sort -rn \
    | head -20 \
    | while read -r count word; do
        if [[ "$count" -ge 2 ]]; then
            printf "  %3d × %s\n" "$count" "$word"
        fi
    done

echo ""

# --- Find similar recommendations ---
echo "## Potential Promotion Candidates (similar recommendations)"
echo ""

# Group recommendations by first significant word
grep '^\- \*\*Recommendation\*\*' "$LEARNINGS" \
    | grep -v '\[PROMOTED\]' \
    | sed 's/.*Recommendation\*\*:\s*//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | while read -r count rec; do
        if [[ "$count" -ge 3 ]]; then
            echo "  PROMOTE ($count occurrences): $rec"
        elif [[ "$count" -ge 2 ]]; then
            echo "  WATCH  ($count occurrences): $rec"
        fi
    done

echo ""

# --- Context patterns ---
echo "## Context Patterns (recurring themes)"
echo ""

grep '^\- \*\*Context\*\*' "$LEARNINGS" \
    | grep -v '\[PROMOTED\]' \
    | sed 's/.*Context\*\*:\s*//' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -s ' ' '\n' \
    | grep -E '^[a-z]{4,}' \
    | sort | uniq -c | sort -rn \
    | head -10 \
    | while read -r count word; do
        if [[ "$count" -ge 3 ]]; then
            printf "  %3d × %s\n" "$count" "$word"
        fi
    done

echo ""
echo "================================"
echo "Review candidates above. Use /learn Step 4 to promote patterns with 3+ occurrences."
