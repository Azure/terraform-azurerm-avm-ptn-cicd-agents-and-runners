#!/usr/bin/env bash
set -euo pipefail
if [ -n "${AVM_E2E_GITHUB_TOKEN:-}" ]; then
  printf 'GITHUB_TOKEN=%s\n' "$AVM_E2E_GITHUB_TOKEN" > .env
fi
