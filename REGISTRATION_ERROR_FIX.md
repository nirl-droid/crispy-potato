# RMM Agent Registration Error - Complete Fix Guide

## 🔴 Problem

```
/usr/local/rmmagent/rmmagentd register
Runtime error: , still error
```

## ✅ Solution

The issue is almost always a missing or corrupted `agentconfig.xml` file.

### Quick Fix (Try This First)

```bash
# 1. Stop the agent
sudo systemctl stop rmmagent

# 2. Create configuration file
sudo bash << 'CONFIG'
cat > /usr/local/rmmagent/agentconfig.xml << 'EOF'
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
CONFIG

# 3. Start agent and register
sudo systemctl start rmmagent
sleep 2
sudo /usr/local/rmmagent/rmmagentd register
```

## 📋 Step-by-Step Troubleshooting

### Step 1: Check if Config File Exists

```bash
ls -la /usr/local/rmmagent/agentconfig.xml
```

**If file doesn't exist:** Create it using the Quick Fix above

**If file exists but is empty or corrupted:** Delete and recreate it

```bash
sudo rm /usr/local/rmmagent/agentconfig.xml
# Then use Quick Fix to create new one
```

### Step 2: Check Agent Service Status

```bash
sudo systemctl status rmmagent
```

**If not running:**
```bash
sudo systemctl start rmmagent
```

**If won't start:**
```bash
sudo systemctl stop rmmagent
# Check logs for errors
sudo journalctl -u rmmagent -n 50
```

### Step 3: Verify Binary and Permissions

```bash
# Check binary exists and is executable
ls -la /usr/local/rmmagent/rmmagentd

# Fix permissions if needed
sudo chown -R root:root /usr/local/rmmagent
sudo chmod 755 /usr/local/rmmagent
sudo chmod 755 /usr/local/rmmagent/rmmagentd
```

### Step 4: Get Detailed Error Message

```bash
sudo /usr/local/rmmagent/rmmagentd register 2>&1 | tee /tmp/error.log
cat /tmp/error.log
```

This shows the actual error, not just "Runtime error"

### Step 5: Check System Logs

```bash
# Systemd journal
sudo journalctl -u rmmagent -n 100 --no-pager

# Agent logs
sudo tail -f /var/log/rmmagent/*.log

# Check if network connectivity issue
ping -c 1 upload1europe1.systemmonitor.eu.com
```

## 🔧 Complete Reinstall Solution

If Quick Fix doesn't work:

```bash
# 1. Stop service
sudo systemctl stop rmmagent

# 2. Remove agent
sudo dnf remove -y rmmagent

# 3. Clean up
sudo rm -rf /usr/local/rmmagent
sudo rm -rf /var/log/rmmagent

# 4. Reinstall
sudo dnf install -y /path/to/rmmagent-2.2.0-1.x86_64.rpm

# 5. Configure
sudo bash << 'CONFIG'
cat > /usr/local/rmmagent/agentconfig.xml << 'EOF'
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
CONFIG

# 6. Start and register
sudo systemctl start rmmagent
sleep 2
sudo /usr/local/rmmagent/rmmagentd register
```

## ❓ Registration Process

When registration starts, you'll be prompted:

```
** Agent registration **
User name: [enter your N-sight username]
Password: [enter your password]
Your current clients:
0) Create new Client/Site
1) [existing clients...]
Select the Client number: [enter client number or 0 for new]
Sites for client [ClientName]:
0) Create new Client/Site
1) [existing sites...]
Select the Site number: [enter site number or 0 for new]
Device Description: [enter description like "Fedora Server"]

Please check registration data:
Client: [ClientName]
Site: [SiteName]
Device Description: "[Description]"
Want to continue registration? Answer "yes" or "no": yes

Successfully registered
```

## ✅ Verify Installation

Once registration completes:

```bash
# Check service is running
sudo systemctl status rmmagent

# Check version
/usr/local/rmmagent/rmmagentd --version

# Check logs show successful registration
sudo journalctl -u rmmagent -n 20 | grep -i "register\|connect\|success"

# Verify in N-sight RMM dashboard
# Log into N-sight and check if device appears
```

## 🚨 Common Errors and Fixes

### Error: "No such file or directory"
**Cause:** Agent not installed properly  
**Fix:** Reinstall using dnf/yum

### Error: "Permission denied"
**Cause:** Running without sudo or wrong permissions  
**Fix:** 
```bash
sudo /usr/local/rmmagent/rmmagentd register
sudo chown -R root:root /usr/local/rmmagent
```

### Error: "Cannot connect to server"
**Cause:** Network issue or wrong server address  
**Fix:**
```bash
# Test connectivity
ping upload1europe1.systemmonitor.eu.com
# Check config has correct servers
cat /usr/local/rmmagent/agentconfig.xml
```

### Error: "Authentication failed"
**Cause:** Wrong credentials or invalid user  
**Fix:** Use correct N-sight RMM username/password

### Error: "Runtime error: , still error"
**Cause:** Missing agentconfig.xml  
**Fix:** Create config file using Quick Fix above

## 📞 Final Checklist

Before asking for support:

- [ ] Agent is installed: `ls /usr/local/rmmagent/rmmagentd`
- [ ] Service runs: `sudo systemctl status rmmagent`
- [ ] Config exists: `ls /usr/local/rmmagent/agentconfig.xml`
- [ ] Tried Quick Fix
- [ ] Captured full error: `sudo /usr/local/rmmagent/rmmagentd register 2>&1 | tee error.log`
- [ ] Checked system logs: `sudo journalctl -u rmmagent -n 100`
- [ ] Verified network: `ping upload1europe1.systemmonitor.eu.com`

---

**Most fixes require just the Quick Fix. Try that first!**

