#!/usr/bin/env pwsh
if ($env:AVM_E2E_GITHUB_TOKEN) {
    "GITHUB_TOKEN=$($env:AVM_E2E_GITHUB_TOKEN)" | Set-Content -Path .env
}
