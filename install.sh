#!/bin/bash

################################################################################
#                                                                              #
#    N-SIGHT RMM AGENT - ONE-COMMAND INSTALLATION                              #
#    Repository: https://github.com/nirl-droid/crispy-potato                   #
#                                                                              #
#    Usage:                                                                    #
#      curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
#                                                                              #
################################################################################

set -e

# Configuration
REPO_RAW="https://raw.githubusercontent.com/nirl-droid/crispy-potato/main"
RMM_DIR="/usr/local/rmmagent"
TEMP_DIR="/tmp/rmm-install-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error()   { echo -e "${RED}✗${NC} $*"; }

cleanup() { rm -rf "$TEMP_DIR" 2>/dev/null; }
trap cleanup EXIT

# Check root
if [ "$EUID" -ne 0 ]; then
    log_error "Run as root: curl -sL $REPO_RAW/install.sh | sudo bash"
    exit 1
fi

# Detect OS and package manager
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    else
        log_error "Unsupported OS"
        exit 1
    fi
    log_info "Detected: $OS"
}

# Install dependencies
install_deps() {
    log_info "Installing dependencies..."
    case "$OS" in
        ubuntu|debian)
            apt-get update -qq
            apt-get install -y -qq curl ethtool smartmontools unzip dmidecode >/dev/null
            ;;
        fedora|rhel|centos|rocky|alma)
            if command -v dnf &>/dev/null; then
                dnf install -y -q curl ethtool smartmontools unzip dmidecode
            else
                yum install -y -q curl ethtool smartmontools unzip dmidecode
            fi
            ;;
        opensuse*)
            zypper -n -q in curl ethtool smartmontools unzip dmidecode
            ;;
    esac
    log_success "Dependencies installed"
}

# Download and install package
install_package() {
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    case "$OS" in
        ubuntu|debian)
            PKG="rmmagent_2.2.0_amd64.deb"
            log_info "Downloading $PKG..."
            curl -sL -o "$PKG" "$REPO_RAW/$PKG"
            log_info "Installing package..."
            dpkg -i "$PKG" || apt-get install -f -y
            ;;
        fedora|rhel|centos|rocky|alma)
            PKG="rmmagent-2.2.0-1.x86_64.rpm"
            log_info "Downloading $PKG..."
            curl -sL -o "$PKG" "$REPO_RAW/$PKG"
            log_info "Installing package..."
            if command -v dnf &>/dev/null; then
                dnf install -y "$PKG"
            else
                yum install -y "$PKG"
            fi
            ;;
        opensuse*)
            PKG="rmmagent-2.2.0-1.x86_64.rpm"
            log_info "Downloading $PKG..."
            curl -sL -o "$PKG" "$REPO_RAW/$PKG"
            log_info "Installing package..."
            zypper -n in -l "$PKG"
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    log_success "Package installed"
}

# Create agent configuration
create_config() {
    log_info "Creating agent configuration..."
    cat > "$RMM_DIR/agentconfig.xml" << 'EOF'
[GENERAL]
SERVER1=https://upload1europe1.systemmonitor.eu.com/
SERVER2=https://upload2europe1.systemmonitor.eu.com/
SERVER3=https://upload3europe1.systemmonitor.eu.com/
SERVER4=https://upload4europe1.systemmonitor.eu.com/
USERNAME=nir.l@helfy.co
USERKEY=clmmbbbgiennencienhgdoeamfccnahhjfjedpjdilmpjemaoofcckmlolmenalgfhajbhnhgejbndddcfpcnceffmjpkhnkdgebgabkeiagnbdmdknkceenglennlpk
AGENTMODE=0
[AUTOINSTALL]
AUTOINSTALL=1
[AUTOREMOVE]
AUTOREMOVE=0
EOF
    log_success "Configuration created"
}

# Start service
start_service() {
    log_info "Starting rmmagent service..."
    systemctl daemon-reload
    systemctl enable rmmagent
    systemctl start rmmagent
    sleep 2
    if systemctl is-active rmmagent &>/dev/null; then
        log_success "Service running"
    else
        log_warning "Service may need manual start"
    fi
}

# Main
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║       N-SIGHT RMM AGENT INSTALLER                     ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    
    detect_os
    install_deps
    install_package
    create_config
    start_service
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║              ✓ INSTALLATION COMPLETE                  ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "Next: Register the agent:"
    echo "  sudo $RMM_DIR/rmmagentd register"
    echo ""
    echo "Verify:"
    echo "  sudo systemctl status rmmagent"
    echo ""
}

main "$@"
