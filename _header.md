# Azure Verified Module for CI/CD Agents and Runners

This module deploys self-hosted Azure DevOps Agents and Github Runners with support for both Personal Access Token (PAT) and User Assigned Managed Identity (UAMI) authentication.

> ## ⚠️ Breaking Change
>
> All Azure resources directly managed by this module (resource group, management lock, container app environment, NAT gateway, public IP, private DNS zones, container instance, container registry, container registry tasks and role assignments) have been migrated from the `azurerm` provider to the `azapi` provider. The `azurerm` provider is still required for transitive dependencies (AVM resource modules and example provider blocks), but no resources are managed with it directly.
>
> **Existing state from prior versions will not migrate automatically.** Terraform `moved` blocks do not support cross-provider type changes. To upgrade an existing deployment you must either:
>
> 1. Destroy and re-create the deployment with the new module version, or
> 2. Manually `terraform state rm` each affected `azurerm_*` resource and use `import` blocks to bring them into the new `azapi_resource` addresses.
>
> Greenfield deployments are unaffected.

## Features

- Deploys Azure DevOps Agents with PAT or UAMI authentication
- Deploys Github Runners with PAT or GitHub App authentication
- Supports Azure Container Apps with KEDA auto scaling
- Supports Azure Container Instances
- Supports public or private networking
- Creates all required Azure resources or use existing ones
- No PAT token management required with UAMI authentication

## Authentication Methods

**Azure DevOps**: PAT (token-based) or UAMI (identity-based, no tokens required)
**GitHub**: PAT (token-based) or GitHub App (app-based)

## Prerequisites for UAMI Authentication

**Important**: Before using UAMI authentication with Azure DevOps, the User Assigned Managed Identity must be configured in your Azure DevOps organization:

1. **Add the identity to Azure DevOps**: The UAMI must be added as a service principal in your Azure DevOps organization with an appropriate license (Basic or higher).
2. **Grant agent pool permissions**: The UAMI service principal needs the `Administrator` role on the target agent pool so it can register self-hosted agents.
3. **Organization access**: The UAMI must be a member of the Azure DevOps organization.

See the [Required permissions](#required-permissions) section below for the full least-privilege model and the exact Terraform resources used by the examples.

### Setup Options

- **Option 1**: Use existing pre-configured UAMI (recommended) - requires `user_assigned_managed_identity_creation_enabled = false` and UAMI details
- **Option 2**: Let module create UAMI, then configure it manually in Azure DevOps afterward
- **Option 3**: Use `azure_devops_container_app_uami` example for fully automated setup

> **Note**: This module handles Azure infrastructure provisioning only. Azure DevOps organization configuration is managed separately (either manually or through examples using the azuredevops provider).

## Example Usage

### Azure DevOps with UAMI Authentication

Deploy Azure DevOps Agents using User Assigned Managed Identity - no PAT tokens required.

#### Using Existing UAMI (Recommended)

```hcl
module "azure_devops_agents_uami" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  # Use existing UAMI (must be configured in Azure DevOps first). Only the
  # resource_id is required; the module reads client_id and principal_id from it.
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-uami"

  virtual_network_address_space = "10.0.0.0/16"
}
```

#### Creating New UAMI (Requires Manual Azure DevOps Setup)

```hcl
module "azure_devops_agents_uami" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  # Module creates new UAMI (you must configure it in Azure DevOps after creation)
  user_assigned_managed_identity_creation_enabled = true
  user_assigned_managed_identity_name             = "uami-my-agents"

  virtual_network_address_space = "10.0.0.0/16"
}
```

### Azure DevOps with PAT Authentication

Deploy Azure DevOps Agents using Personal Access Token authentication.

```hcl
module "azure_devops_agents_pat" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  virtual_network_address_space = "10.0.0.0/16"
}
```

### GitHub Runners with PAT Authentication

Deploy GitHub Runners using Personal Access Token authentication.

```hcl
module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-runners"
  location = "uksouth"

  version_control_system_type                  = "github"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_repository            = "my-repository"

  virtual_network_address_space = "10.0.0.0/16"
}
```

## Required permissions

The examples in this repository follow a least-privilege model. The principal that runs Terraform (the *deployer*) and the User Assigned Managed Identity (UAMI) that the agents/runners use at runtime have very different permission requirements - keep them separate.

### Azure (the deployer that runs `terraform apply`)

The identity running Terraform needs to create and manage the resources defined by the module in your subscription / resource group. The minimum built-in roles are:

| Scope | Role | Purpose |
|---|---|---|
| Subscription (or resource group, when `resource_group_creation_enabled = false`) | `Contributor` | Create the resource group, virtual network, container app environment / container instances, container registry, log analytics workspace, UAMI, etc. |
| Resource group containing the UAMI (or any scope where role assignments are written) | `Role Based Access Control Administrator` (or `User Access Administrator`) | The module assigns `AcrPull` on the container registry to the UAMI - the deployer needs permission to create that role assignment. |

> If you provide your own pre-existing UAMI, container registry, virtual network, etc. (`*_creation_enabled = false`), the deployer only needs the rights required to *use* those resources - typically `Reader` on each, plus `Role Based Access Control Administrator` on the registry so the module can grant the UAMI `AcrPull`.

### Azure (the User Assigned Managed Identity used by the agents/runners at runtime)

The UAMI that agents/runners use at runtime is intentionally narrowly scoped. The module assigns it **only** what the agent host needs:

| Scope | Role | Granted by | Purpose |
|---|---|---|---|
| Container registry | `AcrPull` | This module | Pull the agent/runner container image from ACR. |

The UAMI is **not** granted `Contributor`, `AcrPush`, or any subscription-level role. Pipelines that need to deploy Azure resources should use a separate workload identity (for example an Azure DevOps service connection or GitHub OIDC federated credential) - do not reuse the agent registration UAMI for pipeline workloads.

### Azure DevOps (UAMI authentication only)

When `version_control_system_authentication_method = "uami"`, the UAMI must be granted permission inside Azure DevOps to register self-hosted agents into the target pool. The examples do this with two Terraform resources:

```hcl
# 1. Add the UAMI to the Azure DevOps organization as a service principal with
#    the Basic ("express") license.
resource "azuredevops_service_principal_entitlement" "uami" {
  account_license_type = "express"
  origin               = "aad"
  origin_id            = module.uami.principal_id
}

# 2. Grant the UAMI the Administrator role on the organization-level agent
#    pool. The lower-privilege Service Account role only permits an already-
#    registered agent to create sessions and listen for jobs; it does not
#    grant the Manage permission needed to register a new agent. Because
#    this module's containers are ephemeral and call POST /_apis/distributed
#    task/pools/{poolId}/agents on every start, Administrator is the lowest
#    built-in role that works. (A custom role with just Manage added to
#    Service Account would be tighter, but is not Terraformable today.)
resource "azuredevops_securityrole_assignment" "uami_pool_admin" {
  scope       = "distributedtask.agentpoolrole"
  resource_id = azuredevops_agent_pool.this.id
  identity_id = azuredevops_service_principal_entitlement.uami.id
  role_name   = "Administrator"
}
```

Per the [Microsoft docs](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/service-principal-agent-registration?view=azure-devops), `Administrator` on the **organization-level** agent pool is the role a service principal needs to register self-hosted agents. The examples grant it via `azuredevops_securityrole_assignment` with `scope = "distributedtask.agentpoolrole"` and `resource_id = <pool_id>`. No project-queue role assignment is needed: agents register against the org-level pool, and pipeline access to the queue is granted separately via `azuredevops_pipeline_authorization`.

The `identity_id` must be the Azure DevOps Service Principal UUID returned by `azuredevops_service_principal_entitlement` (not the AAD object id) — the provider polls the role assignment until the returned `Identity.ID` matches.

The principal that runs `terraform apply` against Azure DevOps must itself be a [Project Collection Administrator](https://learn.microsoft.com/en-us/azure/devops/organizations/security/look-up-project-collection-administrators) (or otherwise be allowed to manage agent pool security and add service principals to the organization) so it can create the `azuredevops_service_principal_entitlement` and `azuredevops_securityrole_assignment` resources above.

#### Pipeline-level authorization

The examples additionally grant the specific pipeline access to the queue using `azuredevops_pipeline_authorization`. This is what allows a pipeline to run on the pool without an interactive "Authorize resources" approval and is independent of the UAMI's role assignment.

### GitHub (PAT or GitHub App authentication)

When `version_control_system_type = "github"`:

- **PAT**: The PAT supplied via `version_control_system_personal_access_token` needs the [`repo` and `workflow` scopes for repository runners, or `admin:org` for organization runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners). Treat the PAT as a secret (Key Vault, Terraform sensitive variable, etc.); the module does not persist it outside the container app/instance.
- **GitHub App**: The GitHub App must be installed on the target repository or organization with the `Administration: Read & write` permission so it can mint registration tokens. The module accepts the App ID, installation ID, and PEM private key via the `version_control_system_*` variables.

The module never grants the GitHub credential any Azure role - it is consumed only inside the agent container to register runners with GitHub.
