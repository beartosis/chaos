#!/bin/bash
# CHAOS Token Budget Audit
#
# Usage: bash scripts/audit-tokens.sh [project-dir]
#
# Sums character counts of all installed skill metadata, CLAUDE.md,
# and other files that get loaded into Claude's context.
# Helps identify opportunities to reduce token usage.

set -euo pipefail

PROJECT_DIR="${1:-.}"

echo "=== CHAOS Token Budget Audit ==="
echo "Project: $PROJECT_DIR"
echo ""

TOTAL=0

audit_file() {
    local file="$1"
    local label="$2"
    if [[ -f "$file" ]]; then
        local chars
        chars=$(wc -c < "$file")
        printf "  %-50s %6d chars (~%d tokens)\n" "$label" "$chars" $((chars / 4))
        TOTAL=$((TOTAL + chars))
    fi
}

# --- CLAUDE.md ---
echo "## Project Instructions"
audit_file "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md"
echo ""

# --- Skills ---
echo "## Skill Files (loaded on invocation)"
for skill_dir in "$PROJECT_DIR"/.claude/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    for skill_file in "$skill_dir"SKILL.md "$skill_dir"SKILL.md.tmpl; do
        [[ -f "$skill_file" ]] && audit_file "$skill_file" "skills/$skill_name/$(basename "$skill_file")"
    done
done
echo ""

# --- Skills Catalog ---
echo "## Auto-Loaded Files"
audit_file "$PROJECT_DIR/.claude/SKILLS-CATALOG.md" "SKILLS-CATALOG.md"
audit_file "$PROJECT_DIR/.claude/skills/index.yml" "skills/index.yml"
echo ""

# --- Agents (ORDER) ---
if [[ -d "$PROJECT_DIR/.claude/agents" ]]; then
    echo "## Agent Files (ORDER)"
    for agent_file in "$PROJECT_DIR"/.claude/agents/*.md; do
        [[ -f "$agent_file" ]] && audit_file "$agent_file" "agents/$(basename "$agent_file")"
    done
    audit_file "$PROJECT_DIR/.claude/agents/index.yml" "agents/index.yml"
    echo ""
fi

# --- Standards ---
echo "## Standards (loaded on reference)"
for std_file in "$PROJECT_DIR"/standards/**/*.md "$PROJECT_DIR"/standards/*.yml; do
    [[ -f "$std_file" ]] && audit_file "$std_file" "${std_file#$PROJECT_DIR/}"
done
echo ""

# --- Learnings ---
echo "## Learnings"
audit_file "$PROJECT_DIR/.chaos/learnings.md" ".chaos/learnings.md"
echo ""

# --- Summary ---
echo "================================"
printf "TOTAL: %d chars (~%d tokens)\n" "$TOTAL" $((TOTAL / 4))
echo ""
echo "Recommendations:"
echo "  - Skills index.yml: Keep under 2000 chars (metadata only)"
echo "  - SKILLS-CATALOG.md: Consider moving out of .claude/ if >4000 chars"
echo "  - Individual skills: Keep under 3000 chars each"
echo "  - Learnings: Archive if >5000 chars"
