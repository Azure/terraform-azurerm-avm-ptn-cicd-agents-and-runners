#!/usr/bin/env pwsh
if ($env:AVM_E2E_GITHUB_TOKEN) {
    $env:GITHUB_TOKEN = $env:AVM_E2E_GITHUB_TOKEN
}
