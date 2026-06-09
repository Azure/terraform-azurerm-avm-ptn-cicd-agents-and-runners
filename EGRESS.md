# Network egress requirements

When this module is deployed in a private / corp-connected posture
(`use_private_networking = true`, no public IP / NAT gateway, all egress
force-tunneled through a central Azure Firewall) the runner Container App needs
the FQDNs below opened at the firewall before deployments will succeed and
workflows will run.

The list is the result of running real GitHub Actions and Azure DevOps workloads
on private ACA runners and harvesting firewall deny logs until everything was
allowed. Treat it as a living document — package ecosystems your workflows pull
from must be added on top of this baseline.

## GitHub Actions runner control plane

| FQDN | Port/proto | Why |
|---|---:|---|
| `github.com`, `*.github.com`, `api.github.com` | 443 HTTPS | GitHub web/API, runner registration, job polling, KEDA `github-runner` scaler |
| `*.actions.githubusercontent.com` | 443 HTTPS | Actions runtime, OIDC, pipeline orchestration |
| `vstoken.actions.githubusercontent.com` | 443 HTTPS | Runner token refresh |
| `codeload.github.com` | 443 HTTPS | `actions/checkout` archives |
| `results-receiver.actions.githubusercontent.com` | 443 HTTPS | Actions results and annotations |
| `objects.githubusercontent.com`, `release-assets.githubusercontent.com` | 443 HTTPS | GitHub object/release downloads; Terraform provider redirects |
| `pkg-containers.githubusercontent.com`, `ghcr.io`, `*.ghcr.io` | 443 HTTPS | GHCR images and layers |
| `*.blob.core.windows.net` | 443 HTTPS | Actions cache, artifacts, logs |

For GitHub Enterprise Cloud with Data Residency (`version_control_system_github_url
= "<tenant>.ghe.com"`) also allow `<tenant>.ghe.com` and `api.<tenant>.ghe.com`.

## Azure DevOps agent control plane

| FQDN | Port/proto | Why |
|---|---:|---|
| `dev.azure.com`, `*.dev.azure.com`, `*.visualstudio.com` | 443 HTTPS | Azure DevOps web/API, agent registration, job polling, KEDA `azure-pipelines` scaler |
| `vstmrblobprodcus30.blob.core.windows.net` (and regional equivalents) | 443 HTTPS | Pipeline artifact storage |

## ACA platform and image pulls

| FQDN | Port/proto | Why |
|---|---:|---|
| `mcr.microsoft.com`, `*.data.mcr.microsoft.com`, `*.cdn.mscr.io` | 443 HTTPS | ACA/runner base images and MCR layers |
| `*.azurecr.io`, `*.data.azurecr.io` | 443 HTTPS | ACR login/data where public path is used |
| `*.azureedge.net` | 443 HTTPS | ACA platform manifest CDN (`shavamanifest*` CNAMEs) |
| `*.<region>.azurecontainerapps.io` | 80 HTTP, 443 HTTPS | ACA regional canaries / data-plane |
| `*.ext.azurecontainerapps.dev` | 443 HTTPS | ACA extensions service (`.dev`, not `.io` — easy to miss) |
| `*.servicebus.windows.net` | 443 HTTPS | ACA/KEDA scale trigger dependency |

## Azure control plane and observability

| FQDN | Port/proto | Why |
|---|---:|---|
| `management.azure.com`, `management.core.windows.net` | 443 HTTPS | ARM control plane and compatibility endpoint |
| `login.microsoftonline.com`, `*.login.microsoftonline.com`, `login.microsoft.com`, `*.login.microsoft.com`, `login.windows.net`, `graph.microsoft.com`, `*.identity.azure.net` | 443 HTTPS | Entra ID, Graph, managed identity |
| `*.vault.azure.net`, `*.vaultcore.azure.net` | 443 HTTPS | Key Vault secrets and control plane fallback |
| `*.monitor.azure.com`, `*.ods.opinsights.azure.com`, `*.oms.opinsights.azure.com`, `*.handler.control.monitor.azure.com`, `*.ingest.monitor.azure.com`, `global.handler.control.monitor.azure.com` | 443 HTTPS | Monitor / Log Analytics / AMA |
| `*.azure-automation.net`, `*.agentsvc.azure-automation.net`, `*.guestconfiguration.azure.com` | 443 HTTPS | Automation and Guest Configuration |
| `api.cloud.defender.microsoft.com` | 443 HTTPS | Defender for Cloud API |

## Package and build tools commonly used by runner jobs

These are not required by the module itself but are universally needed by real
workflows. Add or remove based on your stack.

| FQDN | Port/proto | Why |
|---|---:|---|
| `*.npmjs.org`, `*.npmjs.com`, `registry.npmjs.org`, `registry.yarnpkg.com` | 443 HTTPS | Node/Yarn package restore |
| `pypi.org`, `*.pypi.org`, `files.pythonhosted.org`, `releases.astral.sh` | 443 HTTPS | Python / uv package restore |
| `*.nuget.org`, `api.nuget.org` | 443 HTTPS | .NET package restore |
| `*.hashicorp.com`, `*.terraform.io`, `registry.terraform.io`, `releases.hashicorp.com`, `checkpoint-api.hashicorp.com` | 443 HTTPS | Terraform init / provider downloads / version check |
| `check.trivy.dev` | 443 HTTPS | Trivy vulnerability DB / version check |
| `azure.archive.ubuntu.com`, `archive.ubuntu.com`, `security.ubuntu.com` | 80 HTTP, 443 HTTPS | Ubuntu packages |
| `packages.microsoft.com` | 443 HTTPS | Microsoft Linux packages / az CLI / dotnet |

## Webhook scaling mode

When `webhook_scaling_enabled = true` the runner job talks to its own private
Storage Queue at `<account>.privatelink.queue.core.windows.net` — that resolves
to a private IP in your spoke and **does not traverse the firewall**. No new
public FQDN openings are required on the firewall for the queue itself.

The webhook receiver (your Function App / Logic App / APIM policy) lives
outside this module and has its own egress / inbound requirements — see
`WEBHOOKS.md`.

## Notes

- Some of the entries above are wildcarded service tags that may be expressible
  in Azure Firewall as built-in service tags (e.g. `AzureMonitor`,
  `AzureActiveDirectory`, `AzureKeyVault`, `Storage.<region>`,
  `AzureContainerRegistry.<region>`). Where your firewall supports them, prefer
  service tags over per-FQDN rules.
- This list does not enumerate the IP ranges GitHub/AzDO use to deliver webhooks
  to your receiver — those are inbound to a public-facing endpoint and are
  documented at the [GitHub meta API](https://api.github.com/meta) `hooks`
  array and the
  [Azure DevOps inbound IP doc](https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url).
