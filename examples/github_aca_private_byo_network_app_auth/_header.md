# GitHub with Container Apps, bring-your-own VNet and DNS zone, and GitHub App authentication

This example deploys GitHub Runners to Azure Container Apps using a pre-existing virtual network and a caller-managed private DNS zone, with GitHub App authentication. Use this pattern when DNS zones are managed centrally.

## Authentication

This example uses the [`github`](https://registry.terraform.io/providers/integrations/github/latest/docs) provider with credentials supplied via environment variables. Set the GitHub owner (organization or user) and a Personal Access Token before running Terraform (e.g. in your CD workflow):

```bash
export GITHUB_OWNER="<your-organization-or-user>"
export GITHUB_TOKEN="<your-pat>"
```

The `github_application_*` variables configure GitHub App authentication for the *self-hosted runners themselves* — they are distinct from the provider authentication.

For other provider authentication methods (GitHub App installation, GitHub CLI, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication).
