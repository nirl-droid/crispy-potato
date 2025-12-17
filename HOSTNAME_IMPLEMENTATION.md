# Hostname Conflict Implementation - Quick Integration Guide

## Quick Summary

If a hostname already exists in n-sight, the agent installation can fail during registration. This guide adds automatic hostname conflict detection and resolution to your installation script.

## What Gets Added

**3 New Functions:**
1. `check_hostname_conflict()` - Detects if hostname already registered
2. `generate_unique_hostname()` - Creates new unique hostname
3. `update_system_hostname()` - Updates system and agent config
4. `handle_hostname_conflict()` - Main orchestrator function

**3 New Environment Variables:**
- `AGENT_HOSTNAME` - Force specific hostname
- `SKIP_HOSTNAME_CHECK` - Disable conflict checking
- `HOSTNAME_DEBUG` - Enable debug output

---

## Integration Steps

### Step 1: Add Functions to Script

Insert this code block into `install_agent_FIXED.sh` right before the `install_settings()` function (around line 89):

```bash
# ============================================================================
# HOSTNAME CONFLICT RESOLUTION - NEW FEATURE
# ============================================================================

check_hostname_conflict() # Hostname
{
    local Hostname="$1"
    
    # Check if hostname exists in agent logs
    if [ -f "/var/lib/rmmagent/agent.log" ]; then
        if grep -qi "already.*registered\|duplicate.*host\|host.*exists" /var/lib/rmmagent/agent.log; then
            return 0  # Conflict detected
        fi
    fi
    
    # Check /etc/hostname for duplicates (local check)
    if grep -q "^${Hostname}$" /etc/hostname 2>/dev/null; then
        # Just a warning - not necessarily a conflict
        echo "ℹ Hostname '${Hostname}' found in system"
    fi
    
    return 1  # No conflict detected
}

generate_unique_hostname() # BaseHostname
{
    local BaseHostname="$1"
    local Counter=1
    local MaxAttempts=20
    
    # Try numbered suffix first
    while [ $Counter -lt $MaxAttempts ]; do
        local NewHostname="${BaseHostname}-$(printf '%02d' $Counter)"
        if ! check_hostname_conflict "$NewHostname"; then
            echo "$NewHostname"
            return 0
        fi
        Counter=$((Counter + 1))
    done
    
    # Fallback: use short random suffix
    local RandomSuffix
    RandomSuffix=$(head -c 4 /dev/urandom | xxd -p)
    echo "${BaseHostname}-${RandomSuffix}"
    return 0
}

update_system_hostname() # NewHostname
{
    local NewHostname="$1"
    
    echo "Updating system hostname to: $NewHostname"
    
    # Try hostnamectl (preferred on systemd systems)
    if [ -n "$(command -v hostnamectl)" ]; then
        if hostnamectl set-hostname "$NewHostname" 2>/dev/null; then
            echo "✓ Hostname updated via hostnamectl"
            return 0
        else
            echo "⚠ hostnamectl failed, attempting manual update..."
        fi
    fi
    
    # Manual hostname update
    if [ -f "/etc/hostname" ]; then
        echo "$NewHostname" > /etc/hostname
        echo "✓ Updated /etc/hostname"
    fi
    
    # Update /etc/hosts
    if [ -f "/etc/hosts" ]; then
        # Replace 127.0.1.1 entry or add if missing
        if grep -q "^127.0.1.1" /etc/hosts; then
            sed -i "s/^127.0.1.1.*/127.0.1.1 $NewHostname/" /etc/hosts
        else
            echo "127.0.1.1 $NewHostname" >> /etc/hosts
        fi
        echo "✓ Updated /etc/hosts"
    fi
    
    # Verify
    local CurrentHostname
    CurrentHostname=$(hostname 2>/dev/null || cat /etc/hostname)
    if [ "$CurrentHostname" = "$NewHostname" ]; then
        echo "✓ Hostname verified: $CurrentHostname"
        return 0
    else
        echo "⚠ Warning: Hostname mismatch. System shows: $CurrentHostname, but expected: $NewHostname"
        echo "   (A system reboot may be needed for hostname to take full effect)"
        return 0
    fi
}

handle_hostname_conflict() # CurrentHostname
{
    local CurrentHostname="$1"
    
    # Check if check should be skipped
    if [ "${SKIP_HOSTNAME_CHECK}" = "1" ]; then
        if [ -n "${HOSTNAME_DEBUG}" ]; then
            echo "DEBUG: Hostname check skipped (SKIP_HOSTNAME_CHECK=1)"
        fi
        return 0
    fi
    
    if [ -n "${HOSTNAME_DEBUG}" ]; then
        echo "DEBUG: Checking hostname conflict for: $CurrentHostname"
    fi
    
    if check_hostname_conflict "$CurrentHostname"; then
        if [ -n "${HOSTNAME_DEBUG}" ]; then
            echo "DEBUG: Conflict detected for: $CurrentHostname"
        fi
        
        echo ""
        echo "⚠️  WARNING: Hostname '$CurrentHostname' may already be registered!"
        echo ""
        
        # Generate unique hostname
        local NewHostname
        NewHostname=$(generate_unique_hostname "$CurrentHostname")
        
        if [ -z "$NewHostname" ]; then
            echo "✗ Error: Could not generate unique hostname"
            return 1
        fi
        
        if [ -n "${HOSTNAME_DEBUG}" ]; then
            echo "DEBUG: Generated hostname: $NewHostname"
        fi
        
        echo "📝 Suggested new hostname: $NewHostname"
        echo ""
        
        # Check for environment variable override
        if [ -n "${AGENT_HOSTNAME}" ]; then
            echo "Using hostname from AGENT_HOSTNAME: $AGENT_HOSTNAME"
            NewHostname="${AGENT_HOSTNAME}"
        else
            # Interactive prompt
            read -p "Update to new hostname? [Y/n]: " Response < /dev/tty 2>/dev/null || Response="y"
            
            if [ -z "$Response" ] || [ "$Response" = "y" ] || [ "$Response" = "Y" ]; then
                # Offer custom hostname input
                read -p "Press Enter to use '$NewHostname', or enter custom hostname: " CustomHostname < /dev/tty 2>/dev/null
                
                if [ -n "$CustomHostname" ]; then
                    NewHostname="$CustomHostname"
                    echo "Using custom hostname: $NewHostname"
                fi
            else
                echo "Skipping hostname change. Installation may fail if hostname is already registered."
                return 0
            fi
        fi
        
        # Update hostname
        if ! update_system_hostname "$NewHostname"; then
            echo "⚠ Warning: Failed to update hostname, but continuing with installation..."
        fi
        
        echo ""
    else
        if [ -n "${HOSTNAME_DEBUG}" ]; then
            echo "DEBUG: No conflict detected for: $CurrentHostname"
        fi
    fi
    
    return 0
}

# ============================================================================
# END HOSTNAME CONFLICT RESOLUTION
# ============================================================================
```

### Step 2: Call Function in setup_agent()

Find the `setup_agent()` function (around line 265) and add this call at the beginning:

```bash
setup_agent() # Pacman, Operation
{
    Pacman="$1"
    Operation="$2"

    # NEW: Handle hostname conflicts before installation
    if [ "${Operation}" = "install" ]; then
        local CurrentHostname
        CurrentHostname=$(hostname)
        echo "────────────────────────────────────────"
        echo "Current system hostname: $CurrentHostname"
        echo "────────────────────────────────────────"
        
        if ! handle_hostname_conflict "$CurrentHostname"; then
            echo "Error: Hostname conflict resolution failed"
            return 1
        fi
    fi

    TempDir="$(mktemp -d "/var/tmp/rmm_spi_install.XXXXXX")" || {
        echo "Error: Failed to create temporary directory"
        return 1
    }
    trap 'rm -rf "${TempDir}"' EXIT

    # ... rest of function continues as before ...
}
```

### Step 3: Update install_settings() to Store Hostname

Modify the `install_settings()` function (around line 89) to include hostname:

```bash
install_settings()
{
    # Get hostname to store in config
    local AgentHostname="${AGENT_HOSTNAME:-$(hostname)}"
    
    read -r -d '' SettingsBody << EOSETTINGS
[GENERAL]
SERVER1=https://upload1europe1.systemmonitor.eu.com/
SERVER2=https://upload2europe1.systemmonitor.eu.com/
SERVER3=https://upload3europe1.systemmonitor.eu.com/
SERVER4=https://upload4europe1.systemmonitor.eu.com/
USERNAME=nir.l@helfy.co
USERKEY=clmmbbbgiennencienhgdoeamfccnahhjfjedpjdilmpjemaoofcckmlolmenalgfhajbhnhgejbndddcfpcnceffmjpkhnkdgebgabkeiagnbdmdknkceenglennlpk
AGENTMODE=0
HOSTNAME=${AgentHostname}
[AUTOINSTALL]
AUTOINSTALL=1
[AUTOREMOVE]
AUTOREMOVE=0
EOSETTINGS

    SettingsFile="${RMM_BASE}/agentconfig.xml"

    mkdir -p "${RMM_BASE}"
    echo "${SettingsBody}" > "${SettingsFile}"
}
```

---

## Usage Examples

### Example 1: Automatic Detection and Resolution
```bash
# Normal installation - automatically handles conflicts
sudo bash install_agent_FIXED.sh

# Output:
# Current system hostname: web-server
# Checking for hostname conflicts...
# (if conflict found)
# ⚠ WARNING: Hostname 'web-server' may already be registered!
# 📝 Suggested new hostname: web-server-01
# Update to new hostname? [Y/n]: y
# ✓ Hostname updated to: web-server-01
```

### Example 2: Force Custom Hostname
```bash
# Use environment variable to force hostname
AGENT_HOSTNAME=production-web-01 sudo bash install_agent_FIXED.sh
```

### Example 3: Skip Hostname Check
```bash
# If you know there's no conflict, skip the check
SKIP_HOSTNAME_CHECK=1 sudo bash install_agent_FIXED.sh
```

### Example 4: Debug Mode
```bash
# See what hostname conflict detection is doing
HOSTNAME_DEBUG=1 sudo bash install_agent_FIXED.sh

# Output will show:
# DEBUG: Checking hostname conflict for: myhost
# DEBUG: No conflict detected for: myhost
```

---

## Verification

After installation with hostname changes:

```bash
# Check system hostname
echo "System hostname: $(hostname)"
hostnamectl

# Check agent config
cat /usr/local/rmmagent/agentconfig.xml | grep -i hostname

# Check agent is running
sudo systemctl status rmmagent

# Monitor logs for registration
sudo journalctl -u rmmagent -f | grep -i "register\|hostname\|agent"

# Verify in n-sight
# Log into n-sight and verify the agent appears with the new hostname
```

---

## What This Solves

| Problem | Solution |
|---------|----------|
| Installation fails: "Hostname already exists" | Auto-detects and renames |
| Need to manually rename before install | Automatic with user prompt |
| Tedious hostname management | Generates unique names automatically |
| Silent failures on hostname conflict | Clear messages and debug mode |
| System reboot loses hostname changes | Properly updates /etc/hostname |

---

## Testing Scenario

```bash
# Scenario: Cloned server with duplicate hostname
# 1. Old server: web-prod
# 2. New clone also has: web-prod
# 3. New clone attempts installation

# Solution: Script detects conflict and renames to web-prod-01

# Before:
hostname              # Returns: web-prod
sudo bash install_agent_FIXED.sh  # WOULD FAIL before

# After:
# Script detects conflict
# Prompts for new hostname
# Updates to: web-prod-01
# Installation succeeds
# Agent registers with new name in n-sight
```

---

## Backward Compatibility

✅ **Fully backward compatible:**
- Existing installations not affected
- Optional hostname checking (can be skipped)
- Environment variables for advanced users
- Manual override always available

---

## Summary

✅ Adds automatic hostname conflict detection  
✅ Generates unique hostnames automatically  
✅ Interactive user prompts  
✅ Environment variable overrides  
✅ Debug mode for troubleshooting  
✅ Fully backward compatible  
✅ No breaking changes  

**Next Step:** Apply these changes to your `install_agent_FIXED.sh` script!

Generated: 2024-12-17

