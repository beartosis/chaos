#!/bin/bash
#
# CHAOS Framework Uninstaller
#
# Removes CHAOS from a project, restoring it to pre-installation state.
#
# Usage:
#   cd ~/my-project
#   ~/chaos/uninstall.sh
#
# Options:
#   --force    Skip confirmation prompts (for CI/scripts)
#

set -euo pipefail

# Parse arguments
FORCE_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--force]"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

echo ""
print_header "=================================="
print_header "  CHAOS Framework Uninstaller"
print_header "=================================="
echo ""

# Check if CHAOS is installed
if [[ ! -f ".chaos/framework/version" ]]; then
    print_error "CHAOS is not installed in this project."
    exit 1
fi

# Check for ORDER installation
if [[ -d ".chaos/framework/order" ]]; then
    print_error "ORDER is installed. Please uninstall ORDER first:"
    echo "  ~/order/uninstall.sh"
    exit 1
fi

# Show what will be removed
echo "The following will be removed:"
echo "  - .claude/skills/ (skill definitions)"
echo "  - .claude/scripts/ (helper scripts)"
echo "  - .claude/settings.local.json"
echo "  - .claude/SKILLS-CATALOG.md"
echo "  - standards/ (coding standards)"
echo "  - .chaos/framework/ (framework config)"
echo "  - CLAUDE.md (project instructions)"
echo ""

# Show what will be preserved
echo "The following will be preserved (if they have content):"
echo "  - .chaos/learnings.md (if >10 lines)"
echo ""

# Check for backups that will be restored
if [[ -f ".claude/settings.local.json.backup" ]]; then
    echo "Will restore: .claude/settings.local.json from backup"
fi
if [[ -f "CLAUDE.md.backup" ]]; then
    echo "Will restore: CLAUDE.md from backup"
fi
echo ""

# Confirm
if [[ "$FORCE_MODE" = true ]]; then
    echo "Removing CHAOS (--force mode)..."
else
    read -p "Remove CHAOS from this project? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        exit 1
    fi
fi

echo ""
print_header "Removing CHAOS..."
echo ""

# Step 1: Remove skills
echo "Removing skills..."
rm -rf .claude/skills
print_success "Skills removed"

# Step 2: Remove scripts
echo "Removing scripts..."
rm -rf .claude/scripts
print_success "Scripts removed"

# Step 3: Remove settings (restore backup if exists)
echo "Removing settings..."
if [[ -f ".claude/settings.local.json.backup" ]]; then
    mv .claude/settings.local.json.backup .claude/settings.local.json
    print_success "Settings restored from backup"
else
    rm -f .claude/settings.local.json
    print_success "Settings removed"
fi

# Step 4: Remove skills catalog
rm -f .claude/SKILLS-CATALOG.md

# Step 5: Remove CLAUDE.md (restore backup if exists)
echo "Removing CLAUDE.md..."
if [[ -f "CLAUDE.md.backup" ]]; then
    mv CLAUDE.md.backup CLAUDE.md
    print_success "CLAUDE.md restored from backup"
else
    rm -f CLAUDE.md
    print_success "CLAUDE.md removed"
fi

# Step 6: Handle standards directory
echo "Handling standards directory..."
rm -rf standards
print_success "standards/ removed"

# Step 7: Remove framework configuration
echo "Removing framework configuration..."
rm -rf .chaos/framework
print_success ".chaos/framework/ removed"

# Step 8: Handle remaining .chaos directory (preserve learnings if they have content)
echo "Handling learnings..."
if [[ -f ".chaos/learnings.md" ]]; then
    line_count=$(wc -l < .chaos/learnings.md)
    if [[ $line_count -gt 10 ]]; then
        print_warning ".chaos/learnings.md has content ($line_count lines) — preserving"
        rm -rf .chaos/learnings-archive
    else
        rm -rf .chaos
        print_success ".chaos/ removed (no significant learnings)"
    fi
else
    rm -rf .chaos
    print_success ".chaos/ removed"
fi

# Step 9: Clean up empty .claude directory if nothing left
if [[ -d ".claude" ]]; then
    remaining=$(find .claude -type f 2>/dev/null | wc -l)
    if [[ $remaining -eq 0 ]]; then
        rm -rf .claude
        print_success ".claude/ removed (was empty)"
    else
        print_warning ".claude/ preserved (contains other files)"
    fi
fi

echo ""
print_header "=================================="
print_success "CHAOS uninstalled successfully"
print_header "=================================="
echo ""
echo "Your project has been restored to pre-CHAOS state."
if [[ -d ".chaos" ]]; then
    echo "Note: .chaos/learnings.md was preserved (contains learnings from past sessions)."
fi
echo ""
