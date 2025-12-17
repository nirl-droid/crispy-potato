# GitHub One-Command Setup Guide

## 🎯 Overview

Convert your RMM Agent installation into a one-command setup that can be executed from any SSH session or local terminal directly from your GitHub repository.

## 🚀 Quick Start

### Copy All Files to Your GitHub Repo

Push these files to `https://github.com/nirl-droid/crispy-potato`:

```
crispy-potato/
├── install.sh                          ← One-command installer (NEW)
├── install_agent_FIXED.sh              ← Main agent script
├── README.md                           ← Setup guide
├── QUICK_GUIDE.md                      ← Quick reference
├── HOSTNAME_IMPLEMENTATION.md          ← Hostname feature
└── [other documentation files]
```

### Execute from Terminal

```bash
# Using curl (one-liner from terminal)
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Using wget (alternative)
wget -qO- https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Or download and run locally
curl -O https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh
sudo bash install.sh
```

### From SSH Remote Session

```bash
# SSH into remote machine
ssh user@remote-server

# Run one-command installation
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Wait for completion
# Verify: sudo systemctl status rmmagent
```

---

## 📋 Setup Steps

### Step 1: Prepare GitHub Repository

1. Go to: https://github.com/nirl-droid/crispy-potato
2. Ensure it's a public repository
3. Enable raw file access (should be automatic)

### Step 2: Upload Files to GitHub

```bash
# Clone your repo
git clone https://github.com/nirl-droid/crispy-potato.git
cd crispy-potato

# Copy all files from n-sight_linux_setup
cp /path/to/n-sight_linux_setup/* .

# Ensure install.sh is executable
chmod +x install.sh

# Commit and push
git add .
git commit -m "Add RMM Agent installation scripts"
git push origin main
```

### Step 3: Verify GitHub Raw Content

Test that files are accessible:

```bash
# Test install.sh is accessible
curl -I https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh

# Should return: HTTP/1.1 200 OK
```

### Step 4: Test One-Command Installation

```bash
# On local machine (Ubuntu/Fedora)
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

# Or on remote server via SSH
ssh user@server.com 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
```

---

## 🔧 Customization Options

### Environment Variables

Pass options to the installer:

```bash
# Force specific hostname
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \
  AGENT_HOSTNAME=prod-web-01 sudo bash

# Enable debug mode
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \
  HOSTNAME_DEBUG=1 sudo bash

# Skip hostname checks
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | \
  SKIP_HOSTNAME_CHECK=1 sudo bash
```

### Custom Repository Branch

Modify install.sh to use different branch:

```bash
# Edit install.sh, change:
BRANCH="main"
# To:
BRANCH="develop"
```

Then push and run.

---

## 📊 Usage Scenarios

### Scenario 1: Single Machine Installation

```bash
# On the machine where you want to install
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

### Scenario 2: Remote SSH Installation

```bash
# From local machine, install on remote
ssh ubuntu@192.168.1.100 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'

# Or for multiple servers
for server in 192.168.1.{100..110}; do
  echo "Installing on $server..."
  ssh ubuntu@$server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
done
```

### Scenario 3: Ansible Playbook

```yaml
# playbook.yml
---
- hosts: all
  become: yes
  tasks:
    - name: Download and run RMM Agent installer
      shell: |
        curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | bash
      environment:
        AGENT_HOSTNAME: "{{ inventory_hostname }}"
```

Run with:
```bash
ansible-playbook playbook.yml
```

### Scenario 4: Docker Container

```dockerfile
# Dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl sudo

RUN curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash

CMD ["/bin/bash"]
```

Build and run:
```bash
docker build -t rmm-agent .
docker run -d rmm-agent
```

### Scenario 5: Cloud-Init (AWS/Azure/GCP)

```yaml
#cloud-config
#!/bin/bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

---

## 🔐 Security Best Practices

### 1. HTTPS Only
```bash
# Always use HTTPS, never HTTP
curl -sL https://raw.githubusercontent.com/...  # ✓ Good

# Don't use HTTP
curl -sL http://raw.githubusercontent.com/...   # ✗ Bad
```

### 2. Verify Script Before Running
```bash
# Download first, review, then run
curl -O https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh
cat install.sh  # Review the script
sudo bash install.sh  # Run after review
```

### 3. Pin to Specific Commit

Instead of `main` branch, use specific commit hash:

```bash
# Using specific commit (most secure)
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/abc1234def567.../install.sh | sudo bash

# Using git tag (recommended for releases)
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/refs/tags/v1.0.0/install.sh | sudo bash
```

### 4. Repository Access Control
- Keep repository public (users can review)
- Use GitHub branch protection
- Require pull request reviews
- Monitor changes to install.sh

---

## 🛠️ Troubleshooting

### Script Not Found

```
curl: (22) The requested URL returned error: 404 Not Found
```

**Solution:**
```bash
# Verify file exists on GitHub
curl -I https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh

# Check repository is public
# Check file is in main branch
# Check filename spelling
```

### Permission Denied

```
bash: Permission denied
```

**Solution:**
```bash
# Use sudo
curl -sL https://... | sudo bash

# Or make executable first
curl -O https://...
chmod +x install.sh
sudo bash install.sh
```

### Network Timeout

```
curl: (7) Failed to connect to raw.githubusercontent.com
```

**Solution:**
```bash
# Check internet connection
ping 8.8.8.8

# Try with verbose output
curl -v -sL https://... | sudo bash

# Use wget as alternative
wget -qO- https://... | sudo bash
```

### Script Fails Mid-Installation

```bash
# Check logs
sudo journalctl -u rmmagent -n 50

# Try again with debug
HOSTNAME_DEBUG=1 curl -sL https://... | sudo bash
```

---

## 📈 Monitoring Deployment

### Check Installation Status

```bash
# Verify service is running
sudo systemctl status rmmagent

# Check version
/usr/local/rmmagent/rmmagentd --version

# View recent logs
sudo journalctl -u rmmagent -n 20

# Follow logs in real-time
sudo journalctl -u rmmagent -f
```

### Track Deployments

Add logging to install.sh:

```bash
LOG_FILE="/var/log/rmm-agent-deployment.log"

log_info "Installation started at $(date)" >> $LOG_FILE
log_info "OS: $OS $VERSION" >> $LOG_FILE
log_info "Installation completed at $(date)" >> $LOG_FILE
```

---

## 📚 Documentation Files to Include

Push these to GitHub along with install.sh:

```
crispy-potato/
├── install.sh                          ← Main one-liner installer
├── install_agent_FIXED.sh              ← Full installation script
├── README.md                           ← Getting started
├── QUICK_GUIDE.md                      ← Quick reference
├── HOSTNAME_IMPLEMENTATION.md          ← Hostname feature
├── HOSTNAME_FEATURE_SUMMARY.md         ← Hostname overview
├── HOSTNAME_CONFLICT_RESOLUTION.md     ← Hostname details
├── GITHUB_SETUP.md                     ← This file
└── .gitignore                          ← Ignore temporary files
```

---

## 🚀 One-Liner Commands for Quick Reference

### Ubuntu/Debian
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

### Fedora/RHEL/CentOS
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash
```

### With Custom Hostname
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | AGENT_HOSTNAME=myserver sudo bash
```

### With Debug Output
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | HOSTNAME_DEBUG=1 sudo bash
```

### Via SSH (Remote)
```bash
ssh user@server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
```

### Multiple Servers (Bash Loop)
```bash
for server in server1 server2 server3; do
  ssh ubuntu@$server 'curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash'
done
```

---

## ✅ Verification Checklist

- [ ] All files pushed to GitHub repository
- [ ] Repository is public
- [ ] install.sh is executable (chmod +x)
- [ ] Raw GitHub URLs are accessible
- [ ] One-liner works on local machine
- [ ] One-liner works on remote SSH
- [ ] Documentation is in repository
- [ ] Script handles errors gracefully
- [ ] Debug mode outputs helpful information
- [ ] Hostname conflict handling works

---

## 📞 Quick Support

### Debug Mode Output
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | HOSTNAME_DEBUG=1 sudo bash
```

### Capture Full Installation Log
```bash
curl -sL https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | sudo bash 2>&1 | tee installation.log
```

### Check What install.sh Downloads
```bash
curl -s https://raw.githubusercontent.com/nirl-droid/crispy-potato/main/install.sh | grep "download_file\|RAW_URL"
```

---

## 🎓 Learning Resources

- [GitHub Raw Content Guide](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files)
- [Curl Manual](https://curl.se/docs/)
- [Bash Script Best Practices](https://mywiki.wooledge.org/BashGuide)
- [Security Best Practices for Scripts](https://github.com/Hexxeh/rpi-update/issues/35)

---

## Summary

✅ One-command installation from GitHub  
✅ Works on local terminal and SSH remote sessions  
✅ Supports multiple distributions (Ubuntu, Fedora, CentOS, RHEL)  
✅ Environment variable customization  
✅ Full error handling and logging  
✅ Security-focused design  

**Ready to deploy anywhere with a single command!** 🚀

Generated: 2024-12-17

