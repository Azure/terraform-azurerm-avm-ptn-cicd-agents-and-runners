# Azure DevOps example with private networking and multi-region

This example deploys Azure DevOps Agents to Azure Container Apps in two regions using private networking and User Assigned Managed Identity (UAMI) authentication. A single UAMI is shared between both regional deployments.

>NOTE: Multi-region support may result in duplicated agent scaling, there is no built-in mechanism to prevent this.
