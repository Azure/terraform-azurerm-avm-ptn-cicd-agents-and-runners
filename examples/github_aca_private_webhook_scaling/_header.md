# GitHub runners with webhook-driven KEDA scaling (private ACA)

This example deploys GitHub Actions self-hosted runners on Azure Container Apps
in a private, bring-your-own-network posture, with **webhook-driven KEDA
scaling** enabled. The default `github-runner` polling scaler is replaced by an
`azure-queue` scaler bound to a private Storage Queue this module provisions.

Sub-second scale-up latency, no GitHub API rate-limit consumption.

See [`WEBHOOKS.md`](../../WEBHOOKS.md) for the receiver contract, sample Python
Function App, and caveats. This example does **not** deploy the receiver - only
the queue, runners, and the RBAC needed for a receiver UAMI to enqueue jobs.

Distinctive bits vs `github_aca_private_byo_network_app_auth`:

- `webhook_scaling_enabled = true` plus the supporting `webhook_*` inputs.
- A separate private DNS zone (`privatelink.queue.core.windows.net`) and a
  dedicated subnet for the queue Private Endpoint.
- A UAMI created in this example stands in for a real webhook receiver and is
  granted `Storage Queue Data Message Sender` by the module.
- `version_control_system_runner_labels` + `runner_no_default_labels` so only
  workflows that target the `demo-webhook` label land on this pool.
- `storage_use_azuread = true` on the azurerm provider (required because the
  webhook Storage Account is AAD-only).
