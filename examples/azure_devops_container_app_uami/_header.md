# Azure DevOps Container Apps with UAMI - Complete Automation Example

This example demonstrates complete end-to-end User Assigned Managed Identity (UAMI) authentication setup for Azure DevOps CI/CD agents - no PAT tokens required and no manual Azure DevOps configuration needed.

## ⚠️ Prerequisites Required

**No manual setup required!** This example provides complete automation including:

1. **Automatic UAMI creation**: Creates User Assigned Managed Identity with proper Azure permissions
2. **Azure DevOps integration**: Automatically configures projects, agent pools, and service connections
3. **Infrastructure deployment**: Deploys Container Apps using the configured UAMI authentication

> **Key benefit**: Fully automated setup - no manual Azure DevOps configuration steps needed!

## Features

- **Complete automation**: UAMI creation, Azure DevOps setup, and infrastructure deployment
- **UAMI authentication**: No PAT tokens required for agent authentication
- **KEDA auto-scaling**: Scale from 0 to N agents based on pipeline queue length
- **Secure networking**: Private virtual networks for all components
- **Two-phase deployment**: Automated UAMI setup followed by infrastructure deployment

## Usage

```hcl
