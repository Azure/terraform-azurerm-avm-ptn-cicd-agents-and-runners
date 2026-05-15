#!/usr/bin/env pwsh
if (Test-Path .env) {
    Remove-Item .env -Force
}
