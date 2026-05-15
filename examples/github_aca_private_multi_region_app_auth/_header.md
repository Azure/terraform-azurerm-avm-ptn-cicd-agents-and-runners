# GitHub with Container Apps, multi-region private networking and GitHub App authentication

This example deploys GitHub Runners to Azure Container Apps in two regions using private networking and GitHub App authentication. The same GitHub App credentials are shared between both regional deployments.

> **Note:** Multi-region deployments may produce duplicate agent scaling — there is no built-in mechanism to coordinate scaling between regions.

## Authentication

This example uses the [`github`](https://registry.terraform.io/providers/integrations/github/latest/docs) provider with credentials supplied via environment variables. Set the GitHub owner (organization or user) and a Personal Access Token before running Terraform (e.g. in your CD workflow):

```bash
export GITHUB_OWNER="<your-organization-or-user>"
export GITHUB_TOKEN="<your-pat>"
```

The `github_application_*` variables configure GitHub App authentication for the *self-hosted runners themselves* — they are distinct from the provider authentication.

For other provider authentication methods (GitHub App installation, GitHub CLI, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication).
