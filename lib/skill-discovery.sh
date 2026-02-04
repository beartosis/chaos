#!/bin/bash
# skill-discovery.sh - Query and discover CHAOS skills
#
# Usage:
#   skill-discovery.sh list                    # List all skills
#   skill-discovery.sh list --invocable        # List user-invocable skills only
#   skill-discovery.sh info <skill-name>       # Show skill details
#   skill-discovery.sh find <trigger-phrase>   # Find skill by trigger
#   skill-discovery.sh agents <skill-name>     # List agents used by skill
#   skill-discovery.sh validate                # Validate registry integrity

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAOS_ROOT="${CHAOS_ROOT:-$(dirname "$SCRIPT_DIR")}"

# Try to find project root (where .CHAOS exists)
if [[ -f ".CHAOS/skill-registry.json" ]]; then
    REGISTRY_PATH=".CHAOS/skill-registry.json"
elif [[ -n "${PROJECT_ROOT:-}" && -f "$PROJECT_ROOT/.CHAOS/skill-registry.json" ]]; then
    REGISTRY_PATH="$PROJECT_ROOT/.CHAOS/skill-registry.json"
else
    REGISTRY_PATH="$CHAOS_ROOT/templates/.CHAOS/skill-registry.json"
fi

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Helper Functions ---
print_header() { echo -e "${BOLD}${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error() { echo -e "${RED}$1${NC}" >&2; }

check_jq() {
    if ! command -v jq &> /dev/null; then
        print_error "Error: jq is required but not installed."
        print_error "Install with: brew install jq (macOS) or apt install jq (Linux)"
        exit 1
    fi
}

check_registry() {
    if [[ ! -f "$REGISTRY_PATH" ]]; then
        print_error "Error: Skill registry not found at $REGISTRY_PATH"
        print_error "Run CHAOS install.sh first to generate the registry."
        exit 1
    fi
}

# --- Commands ---

cmd_list() {
    local invocable_only=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --invocable|-i) invocable_only=true; shift ;;
            *) shift ;;
        esac
    done

    check_jq
    check_registry

    print_header "CHAOS Skills"
    echo ""

    if $invocable_only; then
        echo -e "${CYAN}User-Invocable Skills:${NC}"
        jq -r '.skills | to_entries[] | select(.value.invocable == true) | "  /\(.key) - \(.value.version) - \(.value.security.profile)"' "$REGISTRY_PATH"
    else
        echo -e "${CYAN}Workflow Skills:${NC}"
        jq -r '.skills | to_entries[] | select(.value.category == "workflow") | "  /\(.key) - \(.value.version)"' "$REGISTRY_PATH"
        echo ""
        echo -e "${CYAN}Review Skills:${NC}"
        jq -r '.skills | to_entries[] | select(.value.category == "review") | "  /\(.key) - \(.value.version)"' "$REGISTRY_PATH"
        echo ""
        echo -e "${CYAN}Reference Skills (background):${NC}"
        jq -r '.skills | to_entries[] | select(.value.category == "reference") | "  \(.key) - \(.value.version)"' "$REGISTRY_PATH"
    fi
    echo ""
}

cmd_info() {
    local skill_name="$1"

    check_jq
    check_registry

    # Remove leading slash if present
    skill_name="${skill_name#/}"

    local skill_data
    skill_data=$(jq -r ".skills[\"$skill_name\"]" "$REGISTRY_PATH")

    if [[ "$skill_data" == "null" ]]; then
        print_error "Skill not found: $skill_name"
        echo ""
        echo "Available skills:"
        jq -r '.skills | keys[]' "$REGISTRY_PATH" | sed 's/^/  /'
        exit 1
    fi

    print_header "Skill: $skill_name"
    echo ""

    echo -e "${CYAN}Version:${NC} $(echo "$skill_data" | jq -r '.version')"
    echo -e "${CYAN}Category:${NC} $(echo "$skill_data" | jq -r '.category')"
    echo -e "${CYAN}Command:${NC} $(echo "$skill_data" | jq -r '.command // "N/A (background skill)"')"
    echo -e "${CYAN}Security:${NC} $(echo "$skill_data" | jq -r '.security.profile')"
    echo ""

    echo -e "${CYAN}Arguments:${NC}"
    echo "  Required: $(echo "$skill_data" | jq -r '.arguments.required // [] | if length == 0 then "none" else join(", ") end')"
    echo "  Optional: $(echo "$skill_data" | jq -r '.arguments.optional // [] | if length == 0 then "none" else join(", ") end')"
    echo ""

    echo -e "${CYAN}Agents Used:${NC}"
    echo "$skill_data" | jq -r '.agents[]? // empty' | sed 's/^/  - /'
    [[ $(echo "$skill_data" | jq '.agents | length') -eq 0 ]] && echo "  none"
    echo ""

    echo -e "${CYAN}Triggers:${NC}"
    echo "$skill_data" | jq -r '.triggers[]? // empty' | sed 's/^/  - /'
    echo ""

    echo -e "${CYAN}Estimated Usage:${NC}"
    local min_tokens max_tokens min_dur max_dur
    min_tokens=$(echo "$skill_data" | jq -r '.metrics.estimated_tokens.min // "N/A"')
    max_tokens=$(echo "$skill_data" | jq -r '.metrics.estimated_tokens.max // "N/A"')
    min_dur=$(echo "$skill_data" | jq -r '.metrics.typical_duration_minutes.min // "N/A"')
    max_dur=$(echo "$skill_data" | jq -r '.metrics.typical_duration_minutes.max // "N/A"')
    echo "  Tokens: $min_tokens - $max_tokens"
    echo "  Duration: $min_dur - $max_dur minutes"
    echo ""

    echo -e "${CYAN}Path:${NC} $(echo "$skill_data" | jq -r '.path // "N/A"')"
}

cmd_find() {
    local trigger_phrase="$1"

    check_jq
    check_registry

    print_header "Searching for: $trigger_phrase"
    echo ""

    local matches
    matches=$(jq -r --arg trigger "$trigger_phrase" '
        .skills | to_entries[] |
        select(.value.triggers | . != null and any(. | ascii_downcase | contains($trigger | ascii_downcase))) |
        "\(.key): \(.value.triggers | join(", "))"
    ' "$REGISTRY_PATH")

    if [[ -z "$matches" ]]; then
        print_warning "No skills found matching: $trigger_phrase"
        echo ""
        echo "Try one of these common triggers:"
        jq -r '.skills[].triggers[]? // empty' "$REGISTRY_PATH" | sort -u | head -10 | sed 's/^/  - /'
    else
        echo "$matches" | while read -r line; do
            skill_name="${line%%:*}"
            triggers="${line#*: }"
            echo -e "${GREEN}/$skill_name${NC}"
            echo "  Triggers: $triggers"
        done
    fi
}

cmd_agents() {
    local skill_name="$1"

    check_jq
    check_registry

    skill_name="${skill_name#/}"

    local agents
    agents=$(jq -r ".skills[\"$skill_name\"].agents // []" "$REGISTRY_PATH")

    if [[ "$agents" == "[]" ]]; then
        print_warning "No agents found for skill: $skill_name"
        exit 0
    fi

    print_header "Agents used by /$skill_name"
    echo ""

    echo "$agents" | jq -r '.[]' | sed 's/^/  - /'
}

cmd_validate() {
    check_jq
    check_registry

    print_header "Validating Skill Registry"
    echo ""

    local errors=0

    # Check schema version
    local schema_version
    schema_version=$(jq -r '.metadata.schema_version' "$REGISTRY_PATH")
    echo -e "Schema version: ${CYAN}$schema_version${NC}"

    # Validate each skill has required fields
    echo ""
    echo "Checking skills..."

    for skill in $(jq -r '.skills | keys[]' "$REGISTRY_PATH"); do
        local has_name has_version has_category has_security
        has_name=$(jq -r ".skills[\"$skill\"].name // empty" "$REGISTRY_PATH")
        has_version=$(jq -r ".skills[\"$skill\"].version // empty" "$REGISTRY_PATH")
        has_category=$(jq -r ".skills[\"$skill\"].category // empty" "$REGISTRY_PATH")
        has_security=$(jq -r ".skills[\"$skill\"].security.profile // empty" "$REGISTRY_PATH")

        if [[ -z "$has_name" || -z "$has_version" || -z "$has_category" || -z "$has_security" ]]; then
            print_error "  $skill: Missing required fields"
            errors=$((errors + 1))
        else
            print_success "  $skill: OK"
        fi
    done

    echo ""
    if [[ $errors -eq 0 ]]; then
        print_success "Registry is valid!"
    else
        print_error "Found $errors validation errors"
        exit 1
    fi
}

cmd_help() {
    echo "CHAOS Skill Discovery Tool"
    echo ""
    echo "Usage: skill-discovery.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list [--invocable]      List all skills (or just user-invocable)"
    echo "  info <skill>            Show detailed skill information"
    echo "  find <phrase>           Find skills by trigger phrase"
    echo "  agents <skill>          List agents used by a skill"
    echo "  validate                Validate registry integrity"
    echo "  help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  skill-discovery.sh list"
    echo "  skill-discovery.sh info orchestrate"
    echo "  skill-discovery.sh find \"tech debt\""
    echo "  skill-discovery.sh agents create-spec"
}

# --- Main ---
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        list)     cmd_list "$@" ;;
        info)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: skill-discovery.sh info <skill-name>"
                exit 1
            fi
            cmd_info "$1"
            ;;
        find)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: skill-discovery.sh find <trigger-phrase>"
                exit 1
            fi
            cmd_find "$1"
            ;;
        agents)
            if [[ $# -lt 1 ]]; then
                print_error "Usage: skill-discovery.sh agents <skill-name>"
                exit 1
            fi
            cmd_agents "$1"
            ;;
        validate) cmd_validate ;;
        help|--help|-h) cmd_help ;;
        *)
            print_error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
