#!/usr/bin/env pwsh
# The shared workflow exports settings under their stored AVM_* names; map them to the provider's env vars.
$lines = @()
if ($env:AVM_E2E_GITHUB_TOKEN) {
    $lines += "GITHUB_TOKEN=$($env:AVM_E2E_GITHUB_TOKEN)"
}
if ($env:AVM_BARE_GITHUB_OWNER) {
    $lines += "GITHUB_OWNER=$($env:AVM_BARE_GITHUB_OWNER)"
}
if ($lines) {
    $lines | Set-Content -Path .env
}
