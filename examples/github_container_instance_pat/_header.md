# GitHub minimal example with a container instance, private networking and PAT authentication

This example deploys GitHub Runners to Azure Container Instance using the minimal set of required variables using private networking and Personal Access Token (PAT) authentication.

## Authentication

This example uses the [`github`](https://registry.terraform.io/providers/integrations/github/latest/docs) provider with credentials supplied via environment variables. Set the GitHub owner (organization or user) and a Personal Access Token before running Terraform (e.g. in your CD workflow):

```bash
export GITHUB_OWNER="<your-organization-or-user>"
export GITHUB_TOKEN="<your-pat>"
```

The `github_runners_personal_access_token` variable is a separate token used by the self-hosted runners to register with GitHub and is unrelated to provider authentication.

For other authentication methods (GitHub App installation, GitHub CLI, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication).
