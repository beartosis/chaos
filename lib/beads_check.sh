#!/bin/bash
# beads_check.sh - Verify and optionally install Beads (required for CHAOS)

# Check if Beads is installed
check_beads() {
    if ! command -v bd &>/dev/null; then
        return 1
    fi

    BEADS_VERSION=$(bd --version 2>/dev/null | head -1 || echo "unknown")
    export BEADS_VERSION
    return 0
}

# Attempt to install Beads using Go (official source)
install_beads() {
    echo "Attempting to install Beads..."
    echo ""

    # Try go install (official source: github.com/steveyegge/beads)
    if command -v go &>/dev/null; then
        echo "Installing via Go..."
        if go install github.com/steveyegge/beads/cmd/bd@latest 2>/dev/null; then
            echo "Beads installed successfully via Go"
            return 0
        fi
        echo "Go installation failed."
    else
        echo "Go is not installed. Please install Go first:"
        echo "  https://go.dev/dl/"
    fi

    echo ""
    echo "Automatic installation failed. Please install manually:"
    echo "  go install github.com/steveyegge/beads/cmd/bd@latest"
    echo ""
    echo "Official source: https://github.com/steveyegge/beads"
    return 1
}

# Check for Beads, offer to install if missing
check_or_install_beads() {
    if check_beads; then
        return 0
    fi

    echo ""
    echo "Beads (bd) not found"
    echo ""
    echo "Beads is required for CHAOS orchestration."
    echo ""

    # Check if we're in interactive mode
    if [[ -t 0 ]]; then
        read -p "Would you like to install Beads now? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if install_beads; then
                # Verify installation worked
                if check_beads; then
                    return 0
                fi
            fi
        fi
    fi

    echo ""
    echo "Manual installation:"
    echo "  go install github.com/steveyegge/beads/cmd/bd@latest"
    echo ""
    echo "Official source: https://github.com/steveyegge/beads"
    echo ""
    return 1
}

# Display Beads status
beads_status() {
    if command -v bd &>/dev/null; then
        local version
        version=$(bd --version 2>/dev/null | head -1 || echo "unknown")
        echo "Beads: $version"
    else
        echo "Beads: not installed"
    fi
}
