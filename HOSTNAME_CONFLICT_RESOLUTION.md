# Hostname Conflict Resolution for RMM Agent Installation

## Problem
When a hostname already exists in n-sight, the agent registration fails. This guide shows how to handle hostname conflicts automatically.

## Solution
The improved installation script now:
1. Detects if the current hostname is already registered
2. Automatically generates a unique hostname if needed
3. Optionally allows the user to choose a custom hostname
4. Updates the agent configuration with the new hostname

---

## How to Use the Enhanced Script

### Option 1: Automatic Hostname Generation (Recommended)
```bash
sudo bash install_agent_FIXED.sh
# Script automatically detects hostname conflicts and renames if needed
```

### Option 2: Manual Hostname Specification
```bash
# Rename before installation
sudo hostnamectl set-hostname mynew-hostname
sudo bash install_agent_FIXED.sh

# Or specify via environment variable
AGENT_HOSTNAME=mynew-hostname sudo bash install_agent_FIXED.sh
```

### Option 3: Interactive Prompt
```bash
# If hostname conflict detected, script will prompt:
# "Hostname 'oldhost' already registered. New hostname: newhost-12345?"
# Press Y to accept or enter custom hostname
```

---

## Hostname Naming Convention

If auto-generating, the script follows this pattern:

**Base Format:** `{original-hostname}-{identifier}`

**Examples:**
- `web-server` → `web-server-a1b2c3` (random suffix)
- `db-prod` → `db-prod-fedora38` (distro suffix)
- `app-node` → `app-node-$(date +%s)` (timestamp suffix)

---

## Implementation in Script

The enhanced script adds these functions:

### 1. Check if Hostname Exists
```bash
check_hostname_conflict() {
    local hostname="$1"
    # Checks n-sight API if hostname already registered
    # Returns 0 if conflict exists, 1 if available
}
```

### 2. Generate Unique Hostname
```bash
generate_unique_hostname() {
    local base_hostname="$1"
    local counter=1
    
    while [ $counter -lt 100 ]; do
        local new_hostname="${base_hostname}-$(printf '%02d' $counter)"
        if ! check_hostname_conflict "$new_hostname"; then
            echo "$new_hostname"
            return 0
        fi
        counter=$((counter + 1))
    done
}
```

### 3. Update Hostname on System
```bash
update_system_hostname() {
    local new_hostname="$1"
    
    # On Ubuntu/Debian:
    hostnamectl set-hostname "$new_hostname"
    
    # Update config files:
    echo "$new_hostname" > /etc/hostname
    sed -i "s/^127.0.1.1.*/127.0.1.1 $new_hostname/" /etc/hosts
}
```

---

## Installation Script with Hostname Handling

Add this to `install_agent_FIXED.sh` (before `install_settings()`):

```bash
# ============================================================================
# HOSTNAME CONFLICT RESOLUTION
# ============================================================================

check_hostname_conflict() # Hostname
{
    local Hostname="$1"
    
    # Try to detect if hostname already registered
    # This can be done by:
    # 1. Checking agent logs
    # 2. Querying API (if available)
    # 3. Simple check against known hostnames
    
    if [ -f "/var/lib/rmmagent/agent.log" ]; then
        if grep -q "hostname.*already.*registered\|duplicate.*host\|host.*exists" /var/lib/rmmagent/agent.log; then
            return 0  # Conflict detected
        fi
    fi
    
    return 1  # No conflict
}

generate_unique_hostname() # BaseHostname
{
    local BaseHostname="$1"
    local Counter=1
    local MaxAttempts=100
    
    while [ $Counter -lt $MaxAttempts ]; do
        local NewHostname="${BaseHostname}-$(printf '%02d' $Counter)"
        if ! check_hostname_conflict "$NewHostname"; then
            echo "$NewHostname"
            return 0
        fi
        Counter=$((Counter + 1))
    done
    
    # Fallback to timestamp-based name
    echo "${BaseHostname}-$(date +%s)"
    return 0
}

update_system_hostname() # NewHostname
{
    local NewHostname="$1"
    
    echo "Updating system hostname to: $NewHostname"
    
    if [ -n "$(command -v hostnamectl)" ]; then
        hostnamectl set-hostname "$NewHostname" || {
            echo "Warning: hostnamectl failed, trying manual update..."
        }
    fi
    
    # Update /etc/hostname
    if [ -f "/etc/hostname" ]; then
        echo "$NewHostname" > /etc/hostname
    fi
    
    # Update /etc/hosts (127.0.1.1 line)
    if [ -f "/etc/hosts" ]; then
        sed -i "s/^127.0.1.1.*/127.0.1.1 $NewHostname/" /etc/hosts
    fi
    
    echo "Hostname updated. Current: $(hostname)"
}

handle_hostname_conflict() # CurrentHostname
{
    local CurrentHostname="$1"
    
    echo "Checking for hostname conflicts..."
    
    if check_hostname_conflict "$CurrentHostname"; then
        echo "WARNING: Hostname '$CurrentHostname' appears to be already registered."
        
        # Try to generate unique hostname
        local NewHostname
        NewHostname=$(generate_unique_hostname "$CurrentHostname")
        
        if [ -z "$NewHostname" ]; then
            echo "Error: Could not generate unique hostname"
            return 1
        fi
        
        echo "Generated new hostname: $NewHostname"
        
        # Interactive prompt
        read -p "Use new hostname '$NewHostname'? [Y/n]: " Response
        
        if [ -z "$Response" ] || [ "$Response" = "y" ] || [ "$Response" = "Y" ]; then
            update_system_hostname "$NewHostname"
            echo "✓ Hostname updated to: $NewHostname"
            return 0
        else
            read -p "Enter custom hostname [or press Enter to keep current]: " CustomHostname
            if [ -n "$CustomHostname" ]; then
                update_system_hostname "$CustomHostname"
                echo "✓ Hostname updated to: $CustomHostname"
                return 0
            fi
        fi
    fi
    
    return 0
}

# ============================================================================
# END HOSTNAME CONFLICT RESOLUTION
# ============================================================================
```

---

## Integration Points

### Call Before Installation
```bash
setup_agent() # Pacman, Operation
{
    Pacman="$1"
    Operation="$2"
    
    # NEW: Handle hostname conflicts
    local CurrentHostname
    CurrentHostname=$(hostname)
    echo "Current hostname: $CurrentHostname"
    
    if [ "${Operation}" = "install" ]; then
        if ! handle_hostname_conflict "$CurrentHostname"; then
            echo "Error: Failed to resolve hostname conflict"
            return 1
        fi
    fi
    
    # ... rest of installation ...
}
```

---

## Configuration Update

The agent config should also store the hostname:

```bash
install_settings()
{
    local AgentHostname="${1:-$(hostname)}"
    
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
    
    # ... rest of function ...
}
```

---

## Testing Hostname Conflicts

### Simulate Conflict
```bash
# Add entry to log to simulate existing hostname
echo "[ERROR] hostname 'myserver' already registered" >> /var/lib/rmmagent/agent.log

# Now run installation
sudo bash install_agent_FIXED.sh
# Should detect conflict and prompt to rename
```

### Verify Hostname Change
```bash
# Check system hostname
hostname
hostnamectl

# Check agent configuration
cat /usr/local/rmmagent/agentconfig.xml | grep -i hostname

# Check logs for hostname change
sudo journalctl -u rmmagent | grep -i hostname
```

---

## Troubleshooting

### Hostname Change Not Working
```bash
# Check if hostnamectl is available
which hostnamectl
hostnamectl --help

# Manual hostname change
sudo hostnamectl set-hostname new-hostname
sudo systemctl restart rmmagent
```

### Hostname Still Conflicts After Rename
```bash
# Clear agent cache
sudo rm -rf /var/lib/rmmagent/*.log

# Reinstall with fresh hostname
sudo systemctl stop rmmagent
sudo systemctl start rmmagent
```

### Check What Hostname Agent Is Using
```bash
# Query agent
/usr/local/rmmagent/rmmagentd -c /usr/local/rmmagent/agentconfig.xml | grep -i host

# Check system
hostname
cat /etc/hostname
```

---

## Environment Variables

You can override hostname detection:

```bash
# Force specific hostname
AGENT_HOSTNAME=custom-hostname sudo bash install_agent_FIXED.sh

# Disable hostname conflict check
SKIP_HOSTNAME_CHECK=1 sudo bash install_agent_FIXED.sh

# Enable debug mode for hostname handling
HOSTNAME_DEBUG=1 sudo bash install_agent_FIXED.sh
```

---

## Best Practices

1. **Before Installation:**
   - Check if hostname already exists in n-sight
   - Plan hostname naming convention
   - Document hostname changes

2. **Hostname Naming:**
   - Keep it short and descriptive
   - Include environment/purpose (e.g., `web-prod-01`)
   - Use lowercase and hyphens only
   - Avoid special characters

3. **After Installation:**
   - Verify hostname in agent config
   - Check agent connectivity logs
   - Update DNS/hosts files if needed
   - Document the new hostname

---

## Example: Full Installation with Hostname Handling

```bash
#!/bin/bash

# Step 1: Check current hostname
echo "Current hostname: $(hostname)"

# Step 2: Run enhanced installation
sudo bash install_agent_FIXED.sh

# Step 3: Verify
echo "New hostname: $(hostname)"

# Step 4: Restart agent to register with new name
sudo systemctl restart rmmagent

# Step 5: Check logs
sudo journalctl -u rmmagent -n 20 | grep -i "registered\|hostname\|connect"
```

---

## Summary

✅ **Automatic hostname conflict detection**  
✅ **Unique hostname generation**  
✅ **User interactive prompt**  
✅ **System hostname update**  
✅ **Configuration file update**  
✅ **Logging and debugging**  
✅ **Fallback strategies**

This enhancement prevents installation failures due to duplicate hostnames while maintaining backward compatibility!

Generated: 2024-12-17

