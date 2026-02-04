#!/bin/bash
# CHAOS Framework Installer (Orchestrating Rowdy Claude Agents)
# Run from your project directory: ~/chaos/install.sh

set -euo pipefail

# --- Path Detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAOS_ROOT="$SCRIPT_DIR"
PROJECT_ROOT="$(pwd)"

# --- Source Libraries ---
source "$CHAOS_ROOT/lib/beads_check.sh"
source "$CHAOS_ROOT/lib/template_engine.sh"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# --- Validation ---
validate_installation() {
    # Don't install in the framework directory itself
    if [[ "$PROJECT_ROOT" == "$CHAOS_ROOT" ]]; then
        print_error "Cannot install CHAOS in the framework directory"
        echo ""
        echo "Navigate to your project directory first:"
        echo "  cd /path/to/your/project"
        echo "  $CHAOS_ROOT/install.sh"
        exit 1
    fi

    # Check framework files exist
    if [[ ! -d "$CHAOS_ROOT/templates" ]]; then
        print_error "Framework templates not found at $CHAOS_ROOT/templates"
        exit 1
    fi

    if [[ ! -d "$CHAOS_ROOT/lib" ]]; then
        print_error "Framework libraries not found at $CHAOS_ROOT/lib"
        exit 1
    fi
}

# --- Main Installation ---
main() {
    echo ""
    print_header "=================================="
    print_header "  CHAOS Framework Installer"
    print_header "=================================="
    echo ""
    echo "Framework location: $CHAOS_ROOT"
    echo "Project location:   $PROJECT_ROOT"
    echo ""

    # Validate
    validate_installation

    # Check Beads is installed (required), offer to install if missing
    echo "Checking requirements..."
    if ! check_or_install_beads; then
        print_error "Beads is required for CHAOS. Please install and try again."
        exit 1
    fi
    print_success "Beads: $BEADS_VERSION"
    echo ""

    # Confirm installation
    read -p "Install CHAOS orchestration into this project? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    echo ""
    print_header "Installing CHAOS..."
    echo ""

    # Create directory structure
    echo "Creating directory structure..."
    mkdir -p "$PROJECT_ROOT/.claude"/{agents,skills,scripts}
    mkdir -p "$PROJECT_ROOT/specs"
    mkdir -p "$PROJECT_ROOT/.CHAOS"
    print_success "Directories created"

    # Process and copy agent templates
    echo "Installing agents..."
    local agent_count=0
    for template in "$CHAOS_ROOT/templates/.claude/agents"/*.tmpl; do
        [[ -f "$template" ]] || continue
        filename=$(basename "$template" .tmpl)
        process_template "$template" "$PROJECT_ROOT/.claude/agents/$filename"
        agent_count=$((agent_count + 1))
    done
    # Copy agents index
    if [[ -f "$CHAOS_ROOT/templates/.claude/agents/index.yml" ]]; then
        cp "$CHAOS_ROOT/templates/.claude/agents/index.yml" "$PROJECT_ROOT/.claude/agents/"
    fi
    print_success "$agent_count agents installed"

    # Process and copy skill templates
    echo "Installing skills..."
    local skill_count=0
    for skill_dir in "$CHAOS_ROOT/templates/.claude/skills"/*; do
        [[ -d "$skill_dir" ]] || continue
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_ROOT/.claude/skills/$skill_name"

        # Process .tmpl files
        for template in "$skill_dir"/*.tmpl; do
            [[ -f "$template" ]] || continue
            filename=$(basename "$template" .tmpl)
            process_template "$template" "$PROJECT_ROOT/.claude/skills/$skill_name/$filename"
        done

        # Copy non-template files as-is
        for file in "$skill_dir"/*.md; do
            [[ -f "$file" ]] && [[ ! "$file" =~ \.tmpl$ ]] && cp "$file" "$PROJECT_ROOT/.claude/skills/$skill_name/"
        done

        skill_count=$((skill_count + 1))
    done
    # Copy skills index
    if [[ -f "$CHAOS_ROOT/templates/.claude/skills/index.yml" ]]; then
        cp "$CHAOS_ROOT/templates/.claude/skills/index.yml" "$PROJECT_ROOT/.claude/skills/"
    fi
    print_success "$skill_count skills installed"

    # Install skill registry
    echo "Installing skill registry..."
    if [[ -f "$CHAOS_ROOT/templates/.CHAOS/skill-registry.json" ]]; then
        INSTALL_DATE="$(date -Iseconds)"
        sed -e "s|\${CHAOS_ROOT}|$CHAOS_ROOT|g" \
            -e "s|\${INSTALL_DATE}|$INSTALL_DATE|g" \
            "$CHAOS_ROOT/templates/.CHAOS/skill-registry.json" > "$PROJECT_ROOT/.CHAOS/skill-registry.json"
        print_success "Skill registry installed"
    fi

    # Process and copy scripts
    echo "Installing scripts..."
    for template in "$CHAOS_ROOT/templates/.claude/scripts"/*.tmpl; do
        [[ -f "$template" ]] || continue
        filename=$(basename "$template" .tmpl)
        process_template "$template" "$PROJECT_ROOT/.claude/scripts/$filename"
        chmod +x "$PROJECT_ROOT/.claude/scripts/$filename"
    done
    print_success "Scripts installed"

    # Process settings.local.json
    echo "Configuring Claude Code settings..."
    if [[ -f "$PROJECT_ROOT/.claude/settings.local.json" ]]; then
        print_warning "settings.local.json already exists - backing up to settings.local.json.backup"
        cp "$PROJECT_ROOT/.claude/settings.local.json" "$PROJECT_ROOT/.claude/settings.local.json.backup"
    fi
    process_template "$CHAOS_ROOT/templates/.claude/settings.local.json.tmpl" \
                     "$PROJECT_ROOT/.claude/settings.local.json"
    print_success "Settings configured"

    # Process CLAUDE.md
    echo "Installing project instructions..."
    if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        print_warning "CLAUDE.md already exists - backing up to CLAUDE.md.backup"
        cp "$PROJECT_ROOT/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md.backup"
    fi
    process_template "$CHAOS_ROOT/templates/CLAUDE.md.tmpl" "$PROJECT_ROOT/CLAUDE.md"
    print_success "CLAUDE.md installed"

    # Install skills catalog
    echo "Installing skills catalog..."
    if [[ -f "$CHAOS_ROOT/templates/.claude/SKILLS-CATALOG.md" ]]; then
        cp "$CHAOS_ROOT/templates/.claude/SKILLS-CATALOG.md" "$PROJECT_ROOT/.claude/"
        print_success "Skills catalog installed"
    fi

    # Copy example spec
    echo "Installing example spec..."
    cp "$CHAOS_ROOT/templates/specs/_example.md" "$PROJECT_ROOT/specs/"
    print_success "Example spec installed"

    # Install standards
    echo "Installing standards..."
    mkdir -p "$PROJECT_ROOT/standards"
    cp "$CHAOS_ROOT/templates/standards/standards.yml" "$PROJECT_ROOT/standards/"
    local standard_count=0
    for domain_dir in "$CHAOS_ROOT/templates/standards"/{backend,frontend,global,testing}; do
        [[ -d "$domain_dir" ]] || continue
        domain_name=$(basename "$domain_dir")
        mkdir -p "$PROJECT_ROOT/standards/$domain_name"
        for standard_file in "$domain_dir"/*.md; do
            [[ -f "$standard_file" ]] || continue
            cp "$standard_file" "$PROJECT_ROOT/standards/$domain_name/"
            standard_count=$((standard_count + 1))
        done
    done
    print_success "$standard_count standards installed"

    # Save metadata
    echo "Saving configuration..."
    echo "$CHAOS_ROOT" > "$PROJECT_ROOT/.CHAOS/framework_path"
    cat > "$PROJECT_ROOT/.CHAOS/version" <<EOF
CHAOS_VERSION=0.0.1
BEADS_VERSION="$BEADS_VERSION"
CHAOS_ROOT="$CHAOS_ROOT"
PROJECT_ROOT="$PROJECT_ROOT"
INSTALL_DATE="$(date -Iseconds)"
EOF
    print_success "Configuration saved"

    # Run verification
    echo ""
    echo "Running verification..."
    if "$CHAOS_ROOT/lib/verify.sh" "$PROJECT_ROOT"; then
        echo ""
        print_success "Installation complete!"
    else
        echo ""
        print_warning "Installation complete with warnings"
    fi

    echo ""
    print_header "Next Steps"
    echo ""
    echo "  1. Create a spec interactively:"
    echo "     claude /create-spec"
    echo ""
    echo "  2. Answer questions until the spec is complete"
    echo ""
    echo "  3. Run orchestration:"
    echo "     claude /orchestrate 2025-01-25-my-feature"
    echo ""
    echo "Documentation: $CHAOS_ROOT/docs/"
    echo ""
}

# Run main
main "$@"
