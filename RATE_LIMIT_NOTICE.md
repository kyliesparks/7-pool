# GitHub API Rate Limit Notice

## Current Status
- **Error**: HTTP 429 - Too Many Requests
- **Status**: Rate limited from GitHub API
- **Impact**: Cannot create Codespace via CLI/API

## Workaround Options

### Option 1: Wait and Retry (Recommended)
Wait 1 hour for rate limit reset, then run:
```bash
gh codespace create --repo kyliesparks/7-pool
```

### Option 2: Use GitHub Web UI
1. Go to: https://github.com/kyliesparks/7-pool
2. Click "Code" → "Codespaces" → "Create codespace"
3. Select machine type and create

### Option 3: Pre-configured Machine
For non-terminal environments, use specific machine:
```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/kyliesparks/7-pool/codespaces \
  -f displayName='test-socks5-proxy' \
  -f machineName='Linuxeonics-D4' \
  -f devcontainerPath='.devcontainer/devcontainer.json'
```

## Available Machine Types
Common machine types for Codespaces:
- `Linuxeonics-D4` - 2 cores, 8GB RAM, 32GB storage (default)
- `Linuxeonics-M2` - 2 cores, 8GB RAM, 42GB storage
- `Linuxeonics-L` - 4 cores, 16GB RAM, 64GB storage
- `Linuxeonics-XL` - 8 cores, 32GB RAM, 128GB storage

## Repository Details
- **Repository**: kyliesparks/7-pool
- **Branch**: main
- **Configuration**: .devcontainer/devcontainer.json
- **Purpose**: Testing SOCKS5 proxy through Codespaces

## Once Codespace is Created
1. SSH with SOCKS5 proxy:
   ```bash
   gh codespace ssh --repo kyliesparks/7-pool -- -D 1080
   ```

2. Test proxy (in new terminal):
   ```bash
   curl --socks5 localhost:1080 https://api.github.com/users/kyliesparks
   ```

---
Generated: $(date)
