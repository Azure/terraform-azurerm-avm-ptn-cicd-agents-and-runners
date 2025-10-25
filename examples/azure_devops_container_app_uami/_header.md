# Azure DevOps Container Apps with User Assigned Managed Identity (UAMI) Authentication

This example shows how to deploy Azure DevOps Agents to Azure Container Apps using User Assigned Managed Identity (UAMI) for authentication instead of Personal Access Token (PAT).

## Key Features

- **UAMI Authentication**: Uses User Assigned Managed Identity for agent authentication with Azure DevOps instead of PAT
- **Container Apps**: Deploys agents as Container App Jobs with KEDA scaling
- **Auto Scaling**: Scales from 0 to N based on Azure DevOps queue length
- **Private Networking**: Uses private networking with NAT Gateway for outbound connectivity
- **Complete Infrastructure**: Creates all required Azure resources including VNet, Container Registry, Log Analytics, etc.

## Authentication Method Comparison

| Feature | PAT Authentication | UAMI Authentication |
|---------|-------------------|-------------------|
| Secret Management | Requires PAT token | No secrets required |
| Token Expiry | PAT tokens expire | Identity-based, no expiry |
| Security | Token-based | Azure AD identity-based |
| Maintenance | Manual token rotation | Automatic |
| KEDA Auth | Uses PAT in secrets | Uses managed identity |

## Usage

```hcl
