# GitHub One-Command Setup - Implementation Checklist

## 📋 Step-by-Step Implementation

### Phase 1: Prepare Local Files (5 minutes)

- [ ] Copy `install.sh` from this project
- [ ] Copy `install_agent_FIXED.sh` from this project
- [ ] Copy `README.md`, `QUICK_GUIDE.md`, and other docs
- [ ] Verify all files have correct permissions:
  ```bash
  chmod +x install.sh
  chmod +x install_agent_FIXED.sh
  ```

### Phase 2: Push to GitHub (10 minutes)

```bash
# Clone your repository
git clone https://github.com/nirl-droid/crispy-potato.git
cd crispy-potato

# Add all files
cp /path/to/n-sight_linux_setup/* .
git add .

# Commit
git commit -m "Add RMM Agent installation - one-command setup"

# Push to main branch
git push origin main
```

**Verify push succeeded:**
- [ ] GitHub shows all files in repository
- [ ] Files are in `main` branch
- [ ] Repository is public

### Phase 3: Test One-Command Installation (15 minutes)

#### Local Test (Ubuntu/Fedora)
```bash
# On your local machine
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

**Expected Output:**
```
ℹ Detected OS: ubuntu 22.04
✓ Internet connectivity OK
✓ Downloaded: install_agent_FIXED.sh
✓ RMM Agent installed successfully
✓ Agent service is running
```

- [ ] Installation completes without errors
- [ ] Agent service starts successfully
- [ ] Verify: `sudo systemctl status rmmagent`

#### Remote SSH Test
```bash
# Test on a remote server
ssh ubuntu@remote.server.com 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
```

- [ ] Installation works via SSH
- [ ] Remote agent connects successfully

### Phase 4: Create Documentation (10 minutes)

- [ ] README.md includes GitHub one-liner
- [ ] QUICK_GUIDE.md has quick reference
- [ ] GITHUB_SETUP.md is in repository
- [ ] Examples are clear and tested

---

## 🎯 Quick Reference - Copy These One-Liners

### For Documentation/README

```markdown
## Quick Installation

### One-Command Installation

Execute this single command on any Ubuntu, Debian, Fedora, CentOS, or RHEL machine:

#### Using curl (most systems)
\`\`\`bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
\`\`\`

#### Using wget (if curl not available)
\`\`\`bash
wget -qO- https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
\`\`\`

#### Via SSH (from local machine)
\`\`\`bash
ssh user@remote.server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
\`\`\`

### With Options

#### Force Custom Hostname
\`\`\`bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \\
  AGENT_HOSTNAME=production-web-01 sudo bash
\`\`\`

#### Enable Debug Mode
\`\`\`bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \\
  HOSTNAME_DEBUG=1 sudo bash
\`\`\`

#### Multiple Servers (Bash Loop)
\`\`\`bash
for server in 192.168.1.{100..110}; do
  echo "Installing on \$server..."
  ssh ubuntu@\$server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
done
\`\`\`
```

---

## 🧪 Test Scenarios

### Test 1: Fresh Ubuntu 22.04 Installation

```bash
# Prerequisites
sudo apt-get update

# Run installation
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Verify
sudo systemctl status rmmagent
/usr/local/rmmagent/rmmagentd --version
```

**Expected Results:**
- [ ] No errors during download
- [ ] All dependencies install
- [ ] Service starts successfully
- [ ] Version command works

### Test 2: Fedora 38/39 Installation

```bash
# Run installation
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Verify
sudo systemctl status rmmagent
/usr/local/rmmagent/rmmagentd --version
```

**Expected Results:**
- [ ] dnf/yum dependencies install correctly
- [ ] Hostname conflict detection works
- [ ] Service starts successfully

### Test 3: Remote SSH Installation

```bash
# From local machine
ssh ubuntu@192.168.1.100 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'

# Monitor progress
watch -n 1 ssh ubuntu@192.168.1.100 'sudo systemctl status rmmagent'
```

**Expected Results:**
- [ ] Remote installation completes
- [ ] No interactive prompts (can run unattended)
- [ ] Agent registers successfully

### Test 4: Hostname Override

```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \
  AGENT_HOSTNAME=test-server-01 sudo bash

# Verify hostname
cat /etc/hostname
cat /usr/local/rmmagent/agentconfig.xml | grep HOSTNAME
```

**Expected Results:**
- [ ] Hostname changes to specified value
- [ ] Configuration file updated
- [ ] Agent registers with new name

### Test 5: Debug Mode

```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \
  HOSTNAME_DEBUG=1 sudo bash 2>&1 | tee test-debug.log
```

**Expected Results:**
- [ ] DEBUG lines show in output
- [ ] Hostname conflict check shows details
- [ ] Log file captures all output

---

## 📊 Performance Metrics

### Installation Time

| OS | Time | Notes |
|----|------|-------|
| Ubuntu 22.04 | 3-5 min | Fastest |
| Fedora 38 | 4-6 min | dnf operations slower |
| CentOS 7 | 5-7 min | yum operations slower |

### Download Sizes

| File | Size |
|------|------|
| install.sh | ~8 KB |
| install_agent_FIXED.sh | 52 MB |
| Total | ~52 MB |

---

## 🔗 Sharing Instructions

### For Your Team

Send this to your team:

```
Quick Installation Guide

Installation on any Linux machine (Ubuntu, Fedora, CentOS, RHEL):

1. SSH into the machine or open a terminal
2. Copy and paste this one command:

   curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

3. Enter your password when prompted
4. Wait for installation to complete (~5 minutes)
5. Verify: sudo systemctl status rmmagent

For help:
- Documentation: https://github.com/nirl-droid/crispy-potato#readme
- Issues: https://github.com/nirl-droid/crispy-potato/issues
```

### For Cloud Deployments

AWS EC2 User Data:
```bash
#!/bin/bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | bash
```

Azure Custom Script Extension:
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

---

## ✅ Final Checklist

### Before Going Live

- [ ] All files committed to GitHub
- [ ] Repository is public
- [ ] install.sh is executable
- [ ] URLs are correct (no typos)
- [ ] One-liner tested on Ubuntu
- [ ] One-liner tested on Fedora
- [ ] Remote SSH installation tested
- [ ] Hostname override tested
- [ ] Debug mode tested
- [ ] Documentation complete
- [ ] README has installation instructions
- [ ] GitHub repo description mentions one-command install

### Continuous Maintenance

- [ ] Monitor GitHub issues for problems
- [ ] Update scripts if dependencies change
- [ ] Test periodically on new OS versions
- [ ] Keep documentation current
- [ ] Version tags for releases

---

## 📝 Example README.md Section

Add this to your GitHub README:

```markdown
# RMM Agent - One-Command Installation

## Quick Start

Install on any Linux machine with one command:

\`\`\`bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
\`\`\`

Supports: Ubuntu, Debian, Fedora, CentOS, RHEL

### Installation in 3 Steps

1. **SSH into your machine** (or open terminal locally)
   \`\`\`bash
   ssh user@your-server.com
   \`\`\`

2. **Run the installer**
   \`\`\`bash
   curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
   \`\`\`

3. **Verify installation**
   \`\`\`bash
   sudo systemctl status rmmagent
   \`\`\`

### Advanced Options

#### Custom Hostname
\`\`\`bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \\
  AGENT_HOSTNAME=my-custom-host sudo bash
\`\`\`

#### Multiple Servers
\`\`\`bash
for server in 10.0.0.{1..10}; do
  ssh ubuntu@\$server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
done
\`\`\`

## Supported Operating Systems

- ✅ Ubuntu 18.04, 20.04, 22.04+
- ✅ Debian 10, 11, 12+
- ✅ Fedora 35, 36, 37, 38, 39+
- ✅ CentOS 7, 8
- ✅ RHEL 7, 8, 9+

## Documentation

- [Quick Guide](QUICK_GUIDE.md) - Fast reference
- [GitHub Setup](GITHUB_SETUP.md) - Advanced deployment
- [Hostname Resolution](HOSTNAME_IMPLEMENTATION.md) - Hostname conflicts
```

---

## 🎯 Success Criteria

**Installation is successful when:**

✅ One-liner command works on local machine  
✅ One-liner command works via SSH  
✅ Agent service starts automatically  
✅ Agent connects to monitoring server  
✅ Hostname conflict handling works  
✅ Documentation is clear and complete  
✅ Debug mode provides useful output  

---

## 📞 Troubleshooting Quick Reference

### Problem: "curl: command not found"
**Solution:** Use wget instead or install curl

### Problem: "Permission denied"
**Solution:** Use `sudo` before running command

### Problem: "Cannot download from GitHub"
**Solution:** Check internet, verify GitHub is accessible

### Problem: "Hostname already registered"
**Solution:** Script auto-handles with `-01`, `-02`, etc.

### Problem: "Installation hangs"
**Solution:** Run with debug: `HOSTNAME_DEBUG=1`

---

## 🚀 Next Steps

1. ✅ Push files to GitHub
2. ✅ Test one-liner locally
3. ✅ Test via SSH
4. ✅ Update README.md
5. ✅ Share with team
6. ✅ Monitor for issues
7. ✅ Version and tag releases

---

**Generated:** 2024-12-17  
**Status:** Ready for Production  
**Time to Deploy:** ~30 minutes

