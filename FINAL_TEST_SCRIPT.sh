#!/bin/bash
# Codespaces SOCKS5 Proxy Test Script
# Run this in an interactive terminal

set -e

echo "========================================="
echo "Codespaces SOCKS5 Proxy Test Script"
echo "========================================="
echo ""

# Function to cleanup
cleanup() {
    echo ""
    echo "Cleaning up SSH tunnel..."
    pkill -f "gh codespace ssh.*test-socks5-proxy" 2>/dev/null || true
}

trap cleanup EXIT

# Step 1: Verify Codespace is running
echo "Step 1: Checking Codespace status..."
CODESPACE=$(gh codespace list --repo kyliesparks/7-pool --json name,state --jq '.[] | select(.state == "Available") | .name' 2>/dev/null || echo "")

if [ -z "$CODESPACE" ]; then
    echo "Creating Codespace..."
    gh codespace create --repo kyliesparks/7-pool --machine standardLinux32gb
    echo "Waiting for Codespace to start..."
    sleep 30
    CODESPACE=$(gh codespace list --repo kyliesparks/7-pool --json name,state --jq '.[] | select(.state == "Available") | .name')
fi

echo "✓ Using Codespace: $CODESPACE"
echo ""

# Step 2: Kill any existing SSH connections
echo "Step 2: Cleaning up any existing SSH connections..."
pkill -f "gh codespace ssh.*$CODESPACE" 2>/dev/null || true
sleep 2
echo ""

# Step 3: Start SSH with SOCKS5 proxy
echo "Step 3: Starting SSH with SOCKS5 proxy on port 1080..."
echo "KEEP THIS TERMINAL OPEN - SSH will run in foreground"
echo "Press Ctrl+C to exit, but the proxy will remain active while running"
echo ""

# Start SSH in background so we can continue
nohup gh codespace ssh --repo kyliesparks/7-pool -- -D 1080 -N -o ServerAliveInterval=60 > /tmp/ssh-socks5.log 2>&1 &
SSH_PID=$!

echo "SSH started with PID: $SSH_PID"
sleep 5

# Step 4: Verify port is listening
echo ""
echo "Step 4: Verifying SOCKS5 proxy is active..."
if lsof -i:1080 > /dev/null 2>&1; then
    echo "✓ Port 1080 is listening"
    echo ""
else
    echo "⚠ Port 1080 not yet active (may need more time)"
    echo "Check: lsof -i:1080"
fi

# Step 5: Test SOCKS5 proxy
echo ""
echo "Step 5: Testing SOCKS5 proxy with curl..."
echo ""
echo "Running: curl --socks5 localhost:1080 https://api.github.com/users/kyliesparks"
echo ""

sleep 2

if curl --socks5 localhost:1080 -s https://api.github.com/users/kyliesparks 2>&1 | head -5; then
    echo ""
    echo "✅ SUCCESS! SOCKS5 proxy is working!"
else
    echo ""
    echo "❌ Test failed (port may not be active yet)"
fi

echo ""
echo "========================================="
echo "Test Complete"
echo "========================================="
echo ""
echo "To keep the proxy running, leave this terminal open or use:"
echo "  gh codespace ssh --repo kyliesparks/7-pool -- -D 1080 -N"
echo ""
echo "To test in another terminal, run:"
echo "  curl --socks5 localhost:1080 https://api.github.com/users/kyliesparks"
echo ""
echo "Press Ctrl+C to stop the proxy..."
echo ""

# Keep script running
wait $SSH_PID
