#!/bin/bash

################################################################################
#                                                                              #
#    RMM AGENT - ONE-COMMAND INSTALLATION FROM GITHUB                        #
#    Repository: https://github.com/nirl-droid/crispy-potato                  #
#                                                                              #
#    Usage:                                                                    #
#      curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/   #
#      main/install.sh | sudo bash                                             #
#                                                                              #
#      OR                                                                      #
#                                                                              #
#      wget -qO- https://raw.githubusercontent.com/nirl-droid/crispy-potato/  #
#      main/install.sh | sudo bash                                             #
#                                                                              #
################################################################################

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================

REPO_URL="https://github.com/nirl-droid/crispy-potato"
RAW_URL="https://raw.githubusercontent.com/nirl-droid/crispy-potato/main"
BRANCH="main"
INSTALL_DIR="/opt/rmm-agent"
TEMP_DIR="/tmp/rmm-agent-install-$$"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        echo "Please run with sudo:"
        echo "  curl -sL $RAW_URL/install.sh | sudo bash"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        VERSION=$(rpm -q --qf '%{VERSION}' centos-release)
    else
        log_error "Unsupported operating system"
        exit 1
    fi
    
    log_info "Detected OS: $OS $VERSION"
}

check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_warning "Internet connectivity check failed (non-fatal)"
    else
        log_success "Internet connectivity OK"
    fi
}

create_install_dir() {
    mkdir -p "$INSTALL_DIR" "$TEMP_DIR"
    log_success "Created installation directories"
}

# ============================================================================
# DOWNLOAD FUNCTIONS
# ============================================================================

download_file() {
    local url="$1"
    local output="$2"
    local filename=$(basename "$output")
    
    log_info "Downloading: $filename"
    
    if command -v curl &> /dev/null; then
        curl -sL --fail --show-error -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -q -O "$output" "$url"
    else
        log_error "Neither curl nor wget found. Cannot download files."
        exit 1
    fi
    
    if [ -f "$output" ]; then
        log_success "Downloaded: $filename ($(du -h "$output" | cut -f1))"
    else
        log_error "Failed to download: $filename"
        exit 1
    fi
}

download_scripts() {
    log_info "Downloading RMM Agent scripts from GitHub..."
    
    # Download main installation script
    download_file "$RAW_URL/install_agent_FIXED.sh" "$TEMP_DIR/install_agent_FIXED.sh"
    
    # Download documentation (optional)
    download_file "$RAW_URL/README.md" "$INSTALL_DIR/README.md"
    download_file "$RAW_URL/QUICK_GUIDE.md" "$INSTALL_DIR/QUICK_GUIDE.md"
    
    chmod +x "$TEMP_DIR/install_agent_FIXED.sh"
    log_success "All scripts downloaded and made executable"
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_dependencies() {
    log_info "Installing system dependencies..."
    
    case "$OS" in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl wget git
            ;;
        fedora|rhel|centos)
            if command -v dnf &> /dev/null; then
                dnf install -y curl wget git
            else
                yum install -y curl wget git
            fi
            ;;
    esac
    
    log_success "Dependencies installed"
}

run_installation() {
    log_info "Running RMM Agent installation..."
    
    cd "$TEMP_DIR"
    bash install_agent_FIXED.sh
    
    if [ $? -eq 0 ]; then
        log_success "RMM Agent installed successfully"
    else
        log_error "RMM Agent installation failed"
        exit 1
    fi
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    log_success "Cleanup complete"
}

setup_trap() {
    trap cleanup EXIT INT TERM
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    clear
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║     RMM AGENT - ONE-COMMAND GITHUB INSTALLATION                ║"
    echo "║     Repository: $REPO_URL"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Pre-flight checks
    log_info "Running pre-flight checks..."
    check_root
    detect_os
    check_internet
    
    # Setup
    create_install_dir
    setup_trap
    
    # Download and install
    download_scripts
    install_dependencies
    
    # Run installation
    run_installation
    
    # Verify
    log_info "Verifying installation..."
    if sudo systemctl status rmmagent &> /dev/null; then
        log_success "Agent service is running"
    else
        log_warning "Could not verify agent service status"
    fi
    
    # Summary
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ✓ INSTALLATION COMPLETE                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Verify installation:"
    echo "     sudo systemctl status rmmagent"
    echo ""
    echo "  2. Check agent version:"
    echo "     /usr/local/rmmagent/rmmagentd --version"
    echo ""
    echo "  3. View documentation:"
    echo "     cat $INSTALL_DIR/README.md"
    echo "     cat $INSTALL_DIR/QUICK_GUIDE.md"
    echo ""
    echo "  4. View logs:"
    echo "     sudo journalctl -u rmmagent -f"
    echo ""
}

# ============================================================================
# EXECUTE
# ============================================================================

main "$@"

