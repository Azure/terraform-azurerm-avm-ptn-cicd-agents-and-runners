# GitHub with Container Apps, private networking and PAT authentication

This example deploys GitHub Runners to Azure Container Apps using private networking and Personal Access Token (PAT) authentication.

> **Note:** PAT authentication is provided for backwards compatibility. For new deployments prefer GitHub App authentication — see the `github_aca_private_app_auth` example.

## Authentication

This example uses the [`github`](https://registry.terraform.io/providers/integrations/github/latest/docs) provider with credentials supplied via environment variables. Set the GitHub owner (organization or user) and a Personal Access Token before running Terraform (e.g. in your CD workflow):

```bash
export GITHUB_OWNER="<your-organization-or-user>"
export GITHUB_TOKEN="<your-pat>"
```

The `github_runners_personal_access_token` variable is the PAT used by the *self-hosted runners themselves* to register with GitHub — it is distinct from the provider authentication.

For other provider authentication methods (GitHub App installation, GitHub CLI, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication).
