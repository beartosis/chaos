#!/bin/bash
# verify.sh - Verify CHAOS installation

set -euo pipefail

PROJECT_ROOT="${1:-.}"

verify_installation() {
    local errors=0
    local warnings=0

    echo "Verifying CHAOS installation in $PROJECT_ROOT..."
    echo ""

    # Check directory structure
    echo "Checking directory structure..."

    local required_dirs=(
        ".claude/agents"
        ".claude/skills"
        ".claude/scripts"
        "specs"
        ".CHAOS"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$PROJECT_ROOT/$dir" ]]; then
            echo "  [OK] $dir/"
        else
            echo "  [MISSING] $dir/"
            ((errors++))
        fi
    done

    echo ""

    # Check critical files
    echo "Checking critical files..."

    local required_files=(
        ".claude/scripts/preflight.sh"
        ".claude/skills/orchestrate/SKILL.md"
        ".CHAOS/version"
        "CLAUDE.md"
    )

    for file in "${required_files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            echo "  [OK] $file"
        else
            echo "  [MISSING] $file"
            ((errors++))
        fi
    done

    echo ""

    # Check for hardcoded paths (should not exist)
    echo "Checking for hardcoded paths..."

    local hardcoded
    hardcoded=$(grep -r "/home/bear" "$PROJECT_ROOT/.claude" "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null || true)

    if [[ -n "$hardcoded" ]]; then
        echo "  [WARNING] Found hardcoded paths:"
        echo "$hardcoded" | head -5
        ((warnings++))
    else
        echo "  [OK] No hardcoded paths found"
    fi

    echo ""

    # Check Beads configuration
    echo "Checking configuration..."

    if [[ -f "$PROJECT_ROOT/.CHAOS/version" ]]; then
        source "$PROJECT_ROOT/.CHAOS/version"
        echo "  CHAOS Version: ${CHAOS_VERSION:-unknown}"
        echo "  Beads Version: ${BEADS_VERSION:-unknown}"
    else
        echo "  [ERROR] .CHAOS/version not found"
        ((errors++))
    fi

    echo ""

    # Check preflight script is executable
    if [[ -f "$PROJECT_ROOT/.claude/scripts/preflight.sh" ]]; then
        if [[ -x "$PROJECT_ROOT/.claude/scripts/preflight.sh" ]]; then
            echo "Preflight script is executable: OK"
        else
            echo "Preflight script not executable: fixing..."
            chmod +x "$PROJECT_ROOT/.claude/scripts/preflight.sh"
        fi
    fi

    echo ""

    # Summary
    echo "================================"
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            echo "Verification PASSED"
        else
            echo "Verification PASSED with $warnings warning(s)"
        fi
        return 0
    else
        echo "Verification FAILED with $errors error(s)"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    verify_installation "$@"
fi
