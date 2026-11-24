#!/usr/bin/env pwsh
# The shared workflow exports settings under their stored AVM_BARE_* names; map them to the provider's env vars.
$lines = @()
if ($env:AVM_BARE_AZDO_ORG_SERVICE_URL) {
    $lines += "AZDO_ORG_SERVICE_URL=$($env:AVM_BARE_AZDO_ORG_SERVICE_URL)"
}
if ($env:AVM_BARE_AZDO_PERSONAL_ACCESS_TOKEN) {
    $lines += "AZDO_PERSONAL_ACCESS_TOKEN=$($env:AVM_BARE_AZDO_PERSONAL_ACCESS_TOKEN)"
}
if ($lines) {
    $lines | Set-Content -Path .env
}
