# Codespaces SOCKS5 Proxy Testing Guide

## Overview
This repository is configured for testing Codespaces SOCKS5 proxy functionality.

## Setup Complete ✅

1. **Devcontainer Configuration**
   - Location: `.devcontainer/devcontainer.json`
   - Image: `mcr.microsoft.com/devcontainers/base:ubuntu`
   - Memory: 2GB

2. **Repository**
   - GitHub: `github.com/kyliesparks/7-pool`
   - Branch: `main`
   - Local: `/Users/willson/code/ai/pool/poolside_app/7.pool`

## Testing Instructions

### Prerequisites
- Authenticated as kyliesparks with codespace scope
- gh CLI version 2.30+

### Step 1: Create Codespace
```bash
gh codespace create --repo kyliesparks/7-pool
```

Or use VS Code:
1. Open repository in VS Code
2. Press `Ctrl+Shift+P` (Cmd+Shift+P on Mac)
3. Type "Codespaces: Create New Codespace"
4. Select the repository

### Step 2: SSH with SOCKS5 Proxy
```bash
gh codespace ssh --repo kyliesparks/7-pool -- -D 1080
```

This command:
- Establishes SSH connection to the Codespace
- Sets up SOCKS5 proxy on local port 1080
- Keeps connection active in the foreground

### Step 3: Test SOCKS5 Proxy
In a NEW terminal (keep the SSH terminal running):

```bash
# Test basic connectivity
curl --socks5 localhost:1080 https://api.github.com/users/kyliesparks

# Test with verbose output
curl --socks5 localhost:1080 -v https://api.github.com/users/kyliesparks

# Test DNS resolution through proxy
curl --socks5 localhost:1080 https://ifconfig.me/ip
```

### Expected Output
```json
{
  "login": "kyliesparks",
  "id": ...,
  "type": "User",
  ...
}
```

## Troubleshooting

### Port 1080 already in use
```bash
# Check what's using port 1080
lsof -i :1080

# Use alternative port
gh codespace ssh --repo kyliesparks/7-pool -- -D 1081
curl --socks5 localhost:1081 https://api.github.com/users/kyliesparks
```

### SSH connection fails
- Ensure Codespace is running: `gh codespace list`
- Check status: `gh codespace logs --repo kyliesparks/7-pool`
- Rebuild if needed: `gh codespace rebuild --repo kyliesparks/7-pool`

### curl errors
- Verify SSH is still running
- Check proxy is accepting connections: `nc -zv localhost 1080`
- Test without proxy first: `curl https://api.github.com/users/kyliesparks`

## Additional Testing Commands

### Test with different protocols
```bash
# HTTP
curl --socks5 localhost:1080 http://example.com

# HTTPS
curl --socks5 localhost:1080 https://example.com

# Custom headers
curl --socks5 localhost:1080 -H "User-Agent: Codespaces-SOCKS-Test" https://api.github.com/meta
```

### Test network isolation
```bash
# Bypass proxy for direct connection
curl -x http://localhost:1080 https://api.github.com/users/kyliesparks
```

## Technical Details

### SOCKS5 Protocol
- SOCKS5 is a network proxy protocol
- Supports TCP and UDP traffic
- Username/password authentication (optional)
- Commonly used for:
  - Privacy/anonymity
  - Network tunneling
  - Bypassing firewalls

### SSH Dynamic Forwarding
The `-D 1080` option creates a SOCKS5 proxy server on port 1080, forwarding all traffic through the SSH connection to the Codespace, which acts as a proxy endpoint.

## Completion Checklist

- [x] Repository with devcontainer created
- [x] Code pushed to GitHub
- [ ] Codespace created successfully
- [ ] SSH connection established with SOCKS5 proxy
- [ ] curl test successful

---
Created: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
