#!/bin/bash
set -euo pipefail
echo "Starting mitmproxy in local mode..."
mitmdump --mode local --showhost
