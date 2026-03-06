#!/bin/bash
set -euo pipefail

MITM_DIR="$HOME/.mitmproxy"
CERT_PEM="$MITM_DIR/mitmproxy-ca-cert.pem"

# Generate cert if missing (run mitmdump briefly to trigger generation)
if [ ! -f "$CERT_PEM" ]; then
    echo "Generating mitmproxy certificates..."
    timeout 2 mitmdump --listen-port 9999 || true
fi

# Check if cert is already trusted
if security verify-cert -c "$CERT_PEM" 2>/dev/null; then
    echo "mitmproxy CA already trusted"
else
    echo "Adding mitmproxy CA to login keychain..."
    security add-trusted-cert -r trustRoot -k ~/Library/Keychains/login.keychain-db "$CERT_PEM"
fi
