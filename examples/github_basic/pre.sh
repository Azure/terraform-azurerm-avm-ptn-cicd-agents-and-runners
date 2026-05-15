#!/usr/bin/env bash
# Materializes a .env file with GITHUB_TOKEN for porch shell steps that
# auto-source it (see avm-terraform-governance porch-configs). This keeps
# GITHUB_TOKEN off the host (so host gh cli auth and linting are unaffected)
# and makes it available as a real env var to terraform and gh cli inside
# the container at plan/apply time.
set -euo pipefail
if [ -n "${AVM_E2E_GITHUB_TOKEN:-}" ]; then
  printf 'GITHUB_TOKEN=%s\n' "$AVM_E2E_GITHUB_TOKEN" > .env
fi
