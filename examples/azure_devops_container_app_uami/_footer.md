```

## Prerequisites

Before running this example, you need:

1. **Azure DevOps Organization**: An Azure DevOps organization where you have permissions to create projects and agent pools
2. **Azure Subscription**: An Azure subscription where you can create resources
3. **Azure DevOps PAT**: A Personal Access Token for creating Azure DevOps resources (project, agent pool, repository). This is different from agent authentication which uses UAMI
   - Required scopes: `Agent Pools (Read & Manage)`, `Build (Read & Write)`, `Code (Read & Write)`, `Project and Team (Read & Write)`

## Variables

Set the following variables in `terraform.tfvars`:

```hcl
azure_devops_organization_name    = "your-org-name"
azure_devops_personal_access_token = "your-pat-token-for-setup"
```

## Key Differences from PAT-based Examples

- Sets `version_control_system_authentication_method = "uami"`
- Does NOT require `version_control_system_personal_access_token` for agent authentication
- The agents use the automatically created User Assigned Managed Identity to authenticate with Azure DevOps
- KEDA scaling uses identity-based authentication instead of PAT secrets

## Resources Created

This example creates:

- Azure DevOps Project, Agent Pool, Repository, and Build Pipeline
- Resource Group
- Virtual Network with subnets for Container Apps and Container Registry
- NAT Gateway and Public IP for outbound connectivity
- User Assigned Managed Identity with required permissions
- Azure Container Registry with private endpoint
- Log Analytics Workspace
- Container App Environment
- Container App Jobs (main agent job and placeholder job)
- All necessary RBAC assignments for UAMI authentication

## Notes

- The User Assigned Managed Identity is automatically granted the necessary permissions to authenticate with Azure DevOps
- No PAT tokens are stored in the Container App secrets for agent authentication
- The setup PAT token is only used by the Terraform azuredevops provider to create the initial Azure DevOps resources
- Agents will automatically register and deregister with the Azure DevOps agent pool using UAMI authentication
