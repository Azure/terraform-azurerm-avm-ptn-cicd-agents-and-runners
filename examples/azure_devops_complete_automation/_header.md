# Azure DevOps Complete Automation Example

This example demonstrates a **comprehensive end-to-end automation** for Azure DevOps CI/CD agents using:

- **External UAMI Creation** with proper Azure RBAC permissions
- **Azure DevOps Terraform Provider** for automated project, pool, and permissions setup
- **AVM Pattern Module** using external identity (recommended approach)
- **Complete UAMI Authentication** for both Azure resources and Azure DevOps API
- **Production-Ready Security** following least privilege principles

## Key Features

✅ **Zero Manual Setup** - Complete infrastructure and DevOps automation
✅ **UAMI Authentication** - No PAT tokens required, uses managed identity
✅ **External Identity** - UAMI created outside module (best practice)
✅ **Azure DevOps Provider** - Automated project, pool, and service connection creation
✅ **End-to-End Pipeline** - Working example with all permissions configured

## What Gets Created

### Azure Resources
- Resource Group with all infrastructure
- **External** User Assigned Managed Identity (UAMI)
- Container App Environment and Jobs
- Azure Container Registry
- Log Analytics Workspace
- Virtual Network with security

### Azure DevOps Resources
- DevOps Project with full configuration
- Agent Pool for Container Apps
- Agent Queue with proper permissions
- Service Connection using UAMI
- Git Repository with sample pipeline
- Build Definition with authorization

### RBAC and Permissions
- Azure: Contributor + AcrPush for UAMI
- DevOps: Service connection with UAMI authentication
- Pipeline: Authorized to use pool and service connection
