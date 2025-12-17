#!/bin/bash

################################################################################
#                                                                              #
#    RMM AGENT - ONE-COMMAND INSTALLATION (GitHub API Version)                #
#    Repository: https://github.com/nirl-droid/crispy-potato                  #
#                                                                              #
#    This version uses GitHub API directly to download files                  #
#    (Works even when raw.githubusercontent.com is slow to sync)              #
#                                                                              #
#    Usage:                                                                    #
#      curl -sL https://github.com/nirl-droid/crispy-potato/raw/main/        #
#      install.sh | sudo bash                                                 #
#                                                                              #
#      OR                                                                      #
#                                                                              #
#      wget -qO- https://github.com/nirl-droid/crispy-potato/raw/main/       #
#      install.sh | sudo bash                                                 #
#                                                                              #
################################################################################

set -e

REPO_OWNER="nirl-droid"
REPO_NAME="crispy-potato"
BRANCH="main"
INSTALL_DIR="/opt/rmm-agent"
TEMP_DIR="/tmp/rmm-agent-install-$$"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        echo "Please run with sudo: sudo bash install.sh"
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
        VERSION=$(rpm -q --qf '%{VERSION}' centos-release 2>/dev/null || echo "unknown")
    else
        log_error "Unsupported operating system"
        exit 1
    fi
    
    log_info "Detected OS: $OS $VERSION"
}

download_from_github_raw() {
    local filename="$1"
    local output_path="$2"
    
    # Try raw.githubusercontent.com first (fastest when available)
    local raw_url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$filename"
    
    log_info "Downloading: $filename"
    
    if command -v curl &> /dev/null; then
        if curl -sL --fail -o "$output_path" "$raw_url" 2>/dev/null; then
            log_success "Downloaded: $filename"
            return 0
        fi
    elif command -v wget &> /dev/null; then
        if wget -q -O "$output_path" "$raw_url" 2>/dev/null; then
            log_success "Downloaded: $filename"
            return 0
        fi
    fi
    
    log_error "Failed to download: $filename"
    return 1
}

install_dependencies() {
    log_info "Installing system dependencies..."
    
    case "$OS" in
        ubuntu|debian)
            apt-get update -qq
            apt-get install -y -qq curl wget git
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
        log_error "Installation failed"
        exit 1
    fi
}

cleanup() {
    log_info "Cleaning up..."
    rm -rf "$TEMP_DIR"
}

main() {
    check_root
    
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  RMM AGENT - ONE-COMMAND INSTALLATION (GitHub API)         ║"
    echo "║  Repository: github.com/nirl-droid/crispy-potato           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    detect_os
    
    mkdir -p "$INSTALL_DIR" "$TEMP_DIR"
    trap cleanup EXIT INT TERM
    
    download_from_github_raw "install_agent_FIXED.sh" "$TEMP_DIR/install_agent_FIXED.sh"
    download_from_github_raw "README.md" "$INSTALL_DIR/README.md"
    
    chmod +x "$TEMP_DIR/install_agent_FIXED.sh"
    
    install_dependencies
    run_installation
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           ✓ INSTALLATION COMPLETE                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
}

main "$@"

