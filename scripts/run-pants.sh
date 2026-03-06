#!/bin/bash
set -euo pipefail

USE_PROXY=true
if [[ "${1:-}" == "--no-proxy" ]]; then
    USE_PROXY=false
    shift
fi

TEMP_CACHE=$(mktemp -d)

# If you want to re-download via scie-pants everytime you can uncomment this
# This actually works fine in my setup, but is very slow so I'm just commenting it out
# export SCIE_BASE="$TEMP_CACHE/nce"

if $USE_PROXY; then
    # Tell Python/requests to trust mitmproxy CA (no proxy env vars needed with --mode local)
    export REQUESTS_CA_BUNDLE="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"
    export SSL_CERT_FILE="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"
    echo "Proxy mode: using mitmproxy CA"
else
    echo "Proxy mode: disabled"
fi

echo "Using temp cache: $TEMP_CACHE"

pants \
  --local-store-dir="$TEMP_CACHE/store" \
  --named-caches-dir="$TEMP_CACHE/named_caches" \
  --pants-workdir="$TEMP_CACHE/workdir" \
  -ldebug \
  --no-pantsd \
  "$@"

echo "Cache dir: $TEMP_CACHE"
