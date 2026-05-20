#!/usr/bin/env bash
# Run baseline capture inside a Python 3.9 container.
# Usage: bash run_capture.sh

set -euo pipefail

TAP_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

echo "==> Running baseline capture in python:3.9-slim"
echo "    Tap dir: $TAP_DIR"

docker run --rm \
  -v "$TAP_DIR":/tap \
  -w /tap \
  -e TAP_HUBSPOT_CLIENT_ID="${TAP_HUBSPOT_CLIENT_ID:?}" \
  -e TAP_HUBSPOT_CLIENT_SECRET="${TAP_HUBSPOT_CLIENT_SECRET:?}" \
  -e TAP_HUBSPOT_REFRESH_TOKEN="${TAP_HUBSPOT_REFRESH_TOKEN:?}" \
  -e TAP_HUBSPOT_REDIRECT_URI="${TAP_HUBSPOT_REDIRECT_URI:-https://oauth.peliqan.io/}" \
  -e TAP_HUBSPOT_START_DATE="${TAP_HUBSPOT_START_DATE:-2024-01-01T00:00:00Z}" \
  -e TAP_HUBSPOT_INCLUDE_STREAMS="${TAP_HUBSPOT_INCLUDE_STREAMS:-companies,contacts}" \
  -e AES_SECRET_KEY="peliqan-test-key" \
  python:3.9-slim \
  bash -c "
    apt-get update -qq && apt-get install -y -qq git > /dev/null
    python -m venv /venv
    /venv/bin/pip install -e . -q
    /venv/bin/python tests/regression/capture.py
  "

echo ""
echo "==> Baseline written to tests/regression/baseline/"
