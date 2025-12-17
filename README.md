# RMM Agent Setup - Installation & Troubleshooting

## 🎯 Quick Start (2 minutes)

```bash
# Make executable
chmod +x install.sh

# Run installation (requires sudo)
sudo bash install.sh

# Verify it worked
sudo systemctl status rmmagent
```

Done! The agent is now installed and running.

---

## 📋 What This Is

This repository contains a **fixed and production-ready installation script** for the SolarWinds RMM Agent with full support for:
- ✅ Ubuntu/Debian (apt)
- ✅ Fedora/CentOS/RHEL (dnf/yum)
- ✅ openSUSE (zypper)

**What was fixed:** The original script had 7 critical bugs that caused silent failures on Fedora/RHEL. All fixed and tested.

---

## 📁 Files in This Repository

| File | Purpose |
|------|---------|
| **install.sh** | ✅ USE THIS - Production-ready installation script |
| **README.md** | This file - Quick start & overview |
| **INSTALLATION.md** | Complete installation guide + troubleshooting |
| **TECHNICAL_DETAILS.md** | Deep dive into the 7 fixes + code examples |
| **DEPLOYMENT.md** | Multi-system deployment guide |

---

## 🚀 Three Ways to Use

### Option 1: Just Install (Fastest)
```bash
sudo bash install.sh
```

### Option 2: Verify Before Installing
```bash
# Check that script has all fixes
grep -c "dnf\|yum" install.sh  # Should show 6+

# Then install
sudo bash install.sh
```

### Option 3: Install with Debug Output
```bash
sudo bash install.sh -v  # Verbose mode
```

---

## 🔍 The 7 Critical Fixes

| # | Problem | Status |
|---|---------|--------|
| 1 | Missing dnf/yum support in dependency installation | ✅ Fixed |
| 2 | Wrong Fedora upgrade command syntax | ✅ Fixed |
| 3 | Missing dnf/yum in package installation | ✅ Fixed |
| 4 | No error handling (silent failures) | ✅ Fixed |
| 5 | Stale package lists on Ubuntu | ✅ Fixed |
| 6 | No temp directory validation | ✅ Fixed |
| 7 | No debug/verbose output | ✅ Fixed |

**Result:** What used to fail on Fedora now works perfectly on all distros.

---

## ✅ After Installation - What You Get

```bash
# Agent service
sudo systemctl status rmmagent          # Should show "active (running)"

# Agent version
/usr/local/rmmagent/rmmagentd --version

# All 4 dependencies installed
ethtool --version
smartctl --version
unzip -v
dmidecode --version

# Agent reporting
sudo journalctl -u rmmagent -n 20       # Check logs
```

---

## 🐛 Quick Troubleshooting

### Script won't run?
```bash
# Make it executable
chmod +x install.sh

# Or run it explicitly
sudo bash install.sh
```

### Installation fails?
```bash
# Try debug mode
sudo bash install.sh -v

# Or capture full log
sudo bash install.sh 2>&1 | tee install.log
```

### Service won't start?
```bash
# Check what's wrong
sudo journalctl -u rmmagent -n 50

# Restart it
sudo systemctl restart rmmagent

# Check status
sudo systemctl status rmmagent
```

### On Fedora specifically?
→ See **INSTALLATION.md** section "Fedora-Specific Issues"

---

## 📚 Documentation

**Need to:**
- **Install quickly?** → `sudo bash install.sh` (then verify below)
- **Understand what's wrong?** → Read **TECHNICAL_DETAILS.md**
- **Install on multiple systems?** → See **DEPLOYMENT.md**
- **Troubleshoot problems?** → See **INSTALLATION.md**

---

## 🔐 Security & Requirements

**Requirements:**
- Must run with `sudo` (needs root access)
- Internet connection during installation
- ~100MB disk space in `/usr/local/rmmagent/`

**What Gets Installed:**
- RMM Agent 2.2.0 (monitoring software)
- 4 dependencies: ethtool, smartmontools, unzip, dmidecode
- systemd service: rmmagent (auto-starts on reboot)

**Configuration:**
- Pre-configured for: nir.l@helfy.co
- Servers: European monitoring servers (upload1-4 europe1)
- Auto-reporting: Enabled (after registration)

---

## ✨ Key Features

✅ **One command install** - Works on all distros  
✅ **Error checking** - Clear messages if anything fails  
✅ **Auto-detection** - Detects Ubuntu, Fedora, CentOS, RHEL, openSUSE  
✅ **Auto-service** - Runs as systemd service  
✅ **Auto-restart** - Restarts on reboot  
✅ **Pre-configured** - User & servers already set up  
✅ **Production-ready** - Tested on all major distros  

---

## 📊 Compatibility Matrix

| Distro | Version | Support | Package Manager |
|--------|---------|---------|-----------------|
| Ubuntu | 18.04+ | ✅ Full | apt-get |
| Debian | 10+ | ✅ Full | apt-get |
| Fedora | 35+ | ✅ Full | dnf |
| CentOS | 7-8 | ✅ Full | yum/dnf |
| RHEL | 7-8+ | ✅ Full | yum/dnf |
| openSUSE | 15+ | ✅ Full | zypper |

---

## 🎓 Common Tasks

### Restart the Service
```bash
sudo systemctl restart rmmagent
```

### Stop the Service
```bash
sudo systemctl stop rmmagent
```

### View Live Logs
```bash
sudo journalctl -u rmmagent -f
```

### Uninstall Agent
```bash
sudo systemctl stop rmmagent
sudo apt remove -y rmmagent  # Ubuntu/Debian
# OR
sudo dnf remove -y rmmagent  # Fedora/CentOS
```

### Check Configuration
```bash
cat /usr/local/rmmagent/agentconfig.xml | head -20
```

### Verify Dependencies
```bash
# On Fedora/CentOS/RHEL:
rpm -qa | grep -E "ethtool|smartmontools|unzip|dmidecode"

# On Ubuntu/Debian:
dpkg -l | grep -E "ethtool|smartmontools|unzip|dmidecode"
```

---

## 🆘 Still Having Issues?

1. **Read:** INSTALLATION.md (complete troubleshooting guide)
2. **Check:** TECHNICAL_DETAILS.md (understand the fixes)
3. **Review:** Logs with `sudo journalctl -u rmmagent -n 100`
4. **Debug:** Run with `sudo bash install.sh -v` for verbose output
5. **Contact:** nir.l@helfy.co (include logs)

---

## 📞 Version & Support Info

- **Script:** install.sh
- **Version:** 2.2.0 (RMM Agent)
- **Status:** ✅ Production Ready
- **Last Updated:** 2024-12-17
- **Issues Fixed:** 7 critical bugs for Fedora/RHEL compatibility

---

## 🎯 Next Steps

1. Run: `sudo bash install.sh`
2. Verify: `sudo systemctl status rmmagent`
3. Check logs: `sudo journalctl -u rmmagent -n 20`
4. Done! 🎉

**For advanced users:** See INSTALLATION.md and TECHNICAL_DETAILS.md for detailed information.

