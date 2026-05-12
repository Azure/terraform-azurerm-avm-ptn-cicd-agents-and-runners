# GitHub minimal example with private networking and app authentication

This example deploys GitHub Runners to Azure Container Apps using the minimal set of required variables using private networking.

## Authentication

This example uses the [`github`](https://registry.terraform.io/providers/integrations/github/latest/docs) provider with credentials supplied via environment variables. Set the GitHub owner (organization or user) and a Personal Access Token before running Terraform (e.g. in your CD workflow):

```bash
export GITHUB_OWNER="<your-organization-or-user>"
export GITHUB_TOKEN="<your-pat>"
```

The `github_application_*` variables are passed into the runners module to configure GitHub App authentication for the self-hosted runners themselves and are unrelated to provider authentication.

For other authentication methods (GitHub App installation, GitHub CLI, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication).
