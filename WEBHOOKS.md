# Webhook-Driven Scaling

By default this module uses the KEDA `github-runner` / `azure-pipelines` scaler, which
**polls** the VCS API every `container_app_polling_interval_seconds` (default 30 s) for
queued jobs. That adds 0-30 s of cold-start latency per job and consumes API rate limit.

Setting `webhook_scaling_enabled = true` switches the runner job to a **webhook-driven**
model:

1. This module provisions a private Storage Account + Storage Queue.
2. KEDA scales the runner job using the `azure-queue` scaler (UAMI auth, no secrets).
3. **You** stand up a small webhook receiver that translates VCS webhook events into
   queue messages.

Scale-up latency drops to a few seconds (queue poll interval) and there is no API polling.

---

## Architecture

```
GitHub.com / Azure DevOps
        │  HTTPS webhook (workflow_job / agent.pool.event)
        ▼
┌────────────────────────────────────┐
│  Receiver (Azure Function / Logic  │  ← lives outside this module
│  App / APIM policy)                │    (typically in a hub or
│  - validates HMAC signature        │     internet-facing spoke)
│  - filters event type              │
│  - sends 1 queue message per       │
│    "queued" job, with short TTL    │
└────────────────────────────────────┘
        │  PutMessage (Entra ID / Storage Queue Data Message Sender)
        ▼
┌────────────────────────────────────┐
│  Storage Queue   (created by this  │
│  module, private endpoint only)    │
└────────────────────────────────────┘
        │  KEDA polls queue length (UAMI)
        ▼
┌────────────────────────────────────┐
│  ACA Job — runner replica spawned  │
│  picks up the GitHub / AzDO job    │
└────────────────────────────────────┘
```

> **Why not Service Bus?** Service Bus *private endpoints* require the Premium tier
> (~$680/mo per messaging unit). Storage Queue with a private endpoint is ~$7/mo and the
> KEDA story is identical (UAMI-based, scales on queue length).

---

## Caller prerequisites (required when `webhook_scaling_enabled = true`)

The storage account this module provisions has `shared_access_key_enabled = false`
(AAD-only data plane). All three of the following must be true on the side that runs
`terraform apply`, or the apply will fail when it tries to create the queue:

1. **Provider configuration: `storage_use_azuread = true`**
   ```hcl
   provider "azurerm" {
     features {}
     storage_use_azuread = true
   }
   ```
   Without this, the azurerm provider tries to read queue properties via the shared-key
   data-plane API and gets `403 AuthorizationFailure` /
   `KeyBasedAuthenticationNotPermitted` on an AAD-only account. This module cannot set
   provider config on your behalf — provider blocks belong to the root module.

2. **Deployment identity has data-plane RBAC on the storage account.** The principal
   running Terraform needs `Storage Queue Data Contributor` (or higher) on the storage
   account scope, in addition to its usual control-plane role. ARM `Contributor` /
   `Owner` alone is not enough for data-plane queue operations.

3. **Network reachability to the queue private endpoint.** The storage account has
   `public_network_access_enabled = false`. Your Terraform runner (self-hosted agent,
   ACA build job, Cloud Shell from a peered VNet, etc.) must be able to resolve
   `<account>.privatelink.queue.core.windows.net` and reach it over the private network.
   A Microsoft-hosted runner with no private connectivity cannot complete the apply.

---

## What this module creates when `webhook_scaling_enabled = true`

| Resource | Notes |
|---|---|
| `module.webhook_storage` (AVM `Azure/avm-res-storage-storageaccount/azurerm`) | Standard, ZRS (or LRS), `shared_access_key_enabled = false`, `public_network_access_enabled = false`, OAuth-only. Wraps Storage Account + Queue (`runner-jobs` by default) + Private Endpoint + role assignments in one composable AVM sub-module |
| Runner UAMI → `Storage Queue Data Reader` on the account | So KEDA can read queue length |
| Each principal in `webhook_receiver_principal_ids` → `Storage Queue Data Message Sender` | So your receiver can `Put Message` |

Outputs to wire up your receiver:

- `webhook_queue_name`
- `webhook_storage_account_name`
- `webhook_storage_account_resource_id`
- `webhook_queue_url` (`https://<account>.queue.core.windows.net/<queue>`). Use with Azure
  Storage SDKs.
- `webhook_queue_messages_endpoint` (`https://<account>.queue.core.windows.net/<queue>/messages`).
  Use if you call the Put Message REST API directly.

---

## Receiver contract

The receiver MUST do all of:

1. **Validate the webhook signature.** For GitHub: HMAC-SHA256 of the raw body with the
   webhook secret, compared against `X-Hub-Signature-256`. For Azure DevOps: shared-secret
   basic auth on the service hook subscription.
2. **Filter events.** Only `workflow_job` with `action = "queued"` (GitHub) or
   `ms.vss-pipelines.run-state-changed-event` with state `inProgress` (Azure DevOps).
   Ignore everything else.
3. **Filter by runner labels or pool name (MUST, not SHOULD).** A receiver that scales on
   every `self-hosted` job will spawn runners for jobs that belong to unrelated pools in
   the same org. Match the full label set you registered via
   `version_control_system_runner_labels` (e.g. `["self-hosted","linux","my-pool"]`) or a
   unique label you assign per pool. For AzDO, filter on the exact pool name.
4. **Deduplicate.** GitHub redelivers webhooks; receivers (Function App / APIM) can also
   retry. Build a dedupe key from `{provider, repo_or_org, run_id, job_id, run_attempt}`
   and short-circuit duplicates for a window longer than your message TTL. Without this
   you will over-scale during webhook storms or transient receiver failures.
5. **Send one queue message per *deduped* queued job.** Body can be anything (KEDA only
   looks at queue length); a small JSON with `run_id` / `job_id` / `attempt` is useful
   for tracing.
6. **Set an appropriate message TTL.** Messages exist only to bump queue depth so KEDA
   scales; the runner does not consume them. **Default 300 s** is a safe starting point
   that absorbs cold-start, image pull, firewall/DNS variability, and ACA scheduling
   latency. Tune down to 120-180 s only after measuring your env's p95 cold-start; tune
   up if you see KEDA scaling and the runner failing to claim the job in time.

### Sample: Azure Function (Python, HTTP trigger, Managed Identity)

```python
import hmac, hashlib, json, logging, os
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.storage.queue import QueueClient

app = func.FunctionApp()

WEBHOOK_SECRET = os.environ["GITHUB_WEBHOOK_SECRET"].encode()
QUEUE_URL      = os.environ["QUEUE_URL"]   # from module output `webhook_queue_url`
MESSAGE_TTL    = int(os.environ.get("MESSAGE_TTL", "300"))
REQUIRED_LABELS = set(os.environ.get("REQUIRED_LABELS", "self-hosted,linux").split(","))

_credential = DefaultAzureCredential()
_queue = QueueClient.from_queue_url(QUEUE_URL, credential=_credential)

# Naive in-memory dedupe; replace with Redis/Table Storage for multi-instance.
_seen: dict[str, float] = {}
import time
DEDUPE_TTL = MESSAGE_TTL * 2

def _dedupe(key: str) -> bool:
    now = time.time()
    for k, exp in list(_seen.items()):
        if exp < now: _seen.pop(k, None)
    if key in _seen: return False
    _seen[key] = now + DEDUPE_TTL
    return True

@app.function_name("github_webhook")
@app.route(route="webhook", auth_level=func.AuthLevel.ANONYMOUS, methods=["POST"])
def webhook(req: func.HttpRequest) -> func.HttpResponse:
    body = req.get_body()
    sig  = req.headers.get("X-Hub-Signature-256", "")
    mac  = "sha256=" + hmac.new(WEBHOOK_SECRET, body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(sig, mac):
        return func.HttpResponse("bad signature", status_code=401)

    if req.headers.get("X-GitHub-Event") != "workflow_job":
        return func.HttpResponse("ignored", status_code=204)

    payload = json.loads(body)
    if payload.get("action") != "queued":
        return func.HttpResponse("ignored", status_code=204)

    job = payload["workflow_job"]
    labels = set(job.get("labels") or [])
    if not REQUIRED_LABELS.issubset(labels):
        return func.HttpResponse("labels do not match this pool", status_code=204)

    dedupe_key = f"gh:{job['run_id']}:{job['id']}:{job.get('run_attempt', 1)}"
    if not _dedupe(dedupe_key):
        return func.HttpResponse("duplicate", status_code=204)

    _queue.send_message(
        json.dumps({"run_id": job["run_id"], "job_id": job["id"],
                    "attempt": job.get("run_attempt", 1)}),
        time_to_live=MESSAGE_TTL,
    )
    return func.HttpResponse("queued", status_code=202)
```

Grant the Function's managed identity `Storage Queue Data Message Sender` by passing its
principal ID:

```hcl
module "runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  # ...
  webhook_scaling_enabled        = true
  webhook_receiver_principal_ids = [azurerm_linux_function_app.webhook_receiver.identity[0].principal_id]
}
```

### Sample: Azure DevOps service hook

Add a **service hook** in Project Settings → Service hooks:

- **Service:** Web Hooks
- **Trigger:** Run state changed → state `inProgress` (or `Build queued`)
- **URL:** the Function App `https://<func>.azurewebsites.net/api/webhook`
- **Basic auth:** a shared secret you validate inside the Function
- **Filter by pool:** match your `version_control_system_pool_name` exactly. See receiver
  contract item 3.

> AzDO's run-state events fire on the *run*, not on the *agent job*. They are a coarser
> signal than GitHub's `workflow_job.queued`. If you need precise per-job scale signals
> on AzDO, have the receiver call the AzDO REST API on receipt to resolve the queued
> agent demand for your pool, or accept the imprecision and let the polling fallback
> handle edge cases.

---

## Secret rotation

Webhook mode introduces two new secret categories. Plan rotation up front:

- **Webhook shared secret** (GitHub webhook secret / AzDO basic auth password). Store in
  Key Vault; the receiver should read at startup or per-request. For zero-downtime
  rotation, accept *two* secrets concurrently during the rotation window, then drop the
  old one.
- **Runner credentials are unchanged** in webhook mode. You still need a GitHub PAT,
  GitHub App key, AzDO PAT, or UAMI for the runner to register. Prefer GitHub App over
  PAT (per-installation, revocable, no human ownership). For PAT, document rotation
  cadence and operational impact (rolling job restart to pick up new value).
- **Storage shared keys are disabled** by this module (`shared_access_key_enabled = false`).
  The receiver and KEDA both use AAD; no key rotation needed on the storage side.

---

## Caveats

- **The receiver must be reachable from github.com / dev.azure.com.** That means a
  public ingress point (Function App with public hostname, APIM, Front Door). Corp-style
  policies typically forbid public IPs on resources in *Corp* subscriptions; the standard
  pattern is to host the receiver in a **hub** or **Online** landing zone, not in the
  same Corp subscription as the runners. The queue itself stays private inside Corp.
- **Webhook delivery is best-effort.** GitHub retries failed deliveries for ~24 h;
  receiver-side retries are also common. Implement dedupe per receiver contract item 4
  or accept aggressive over-scaling.
- **Don't try to remove the polling fallback.** If you are nervous about webhook
  delivery losses, leave the receiver in place but also keep `webhook_scaling_enabled = false`
  until you have confidence. There is no hybrid mode in this module (KEDA supports only
  one scaler rule per job here).
- **GitHub PAT / App / AzDO PAT / UAMI are still required** in webhook mode. The receiver
  only triggers scale-up; the runner still uses those credentials to register and pick
  up jobs.

---

## Firewall implications

The runner ACA Job needs egress to its **own** Storage Queue private endpoint. That
resolves to a private IP in your spoke and doesn't traverse the firewall. No new public
FQDN openings are required on the firewall for the queue itself.

The receiver (wherever you host it) needs:

- **Inbound** from GitHub or Azure DevOps webhook IP ranges (see [GitHub meta API](https://api.github.com/meta)
  `hooks` and [AzDO IPs](https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url)).
- **Outbound** to `<account>.privatelink.queue.core.windows.net` via your central DNS.

See `EGRESS.md` for the full FQDN list the runner itself needs at the central firewall.
