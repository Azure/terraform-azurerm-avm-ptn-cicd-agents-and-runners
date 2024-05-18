# resources
resource "azurerm_resource_group" "rg" {
  count = var.resource_group_creation_enabled ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, "rg-${var.name}")

  lifecycle {
    precondition {
      condition     = var.location != null
      error_message = "location must be specified when resource_group_creation_enabled == true"
    }
  }
}

data "azurerm_resource_group" "rg" {
  count = var.resource_group_creation_enabled ? 0 : 1

  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this_vnet" {
  count = var.virtual_network_creation_enabled ? 1 : 0

  address_space       = [var.virtual_network_address_space]
  location            = try(azurerm_resource_group.rg[0].location, data.azurerm_resource_group.rg[0].location)
  name                = coalesce(var.virtual_network_name, "vnet-${var.name}")
  resource_group_name = try(azurerm_resource_group.rg[0].name, data.azurerm_resource_group.rg[0].name)
}

data "azurerm_virtual_network" "this_vnet" {
  count = var.virtual_network_creation_enabled ? 0 : 1

  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

resource "azurerm_subnet" "this_subnet" {
  count = var.subnet_creation_enabled ? 1 : 0

  address_prefixes     = [var.subnet_address_prefix]
  name                 = coalesce(var.subnet_name, "snet-${var.name}")
  resource_group_name  = try(azurerm_virtual_network.this_vnet[0].resource_group_name, var.virtual_network_resource_group_name)
  virtual_network_name = try(azurerm_virtual_network.this_vnet[0].name, var.virtual_network_name)
}

resource "azurerm_log_analytics_workspace" "this_laws" {
  count = var.log_analytics_workspace_creation_enabled ? 1 : 0

  location            = try(azurerm_resource_group.rg[0].location, data.azurerm_resource_group.rg[0].location)
  name                = coalesce(var.log_analytics_workspace_name, "laws-${var.name}")
  resource_group_name = try(azurerm_resource_group.rg[0].name, data.azurerm_resource_group.rg[0].name)
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "ca_ado" {
  source = "./modules/ca-azure-devops-agents"

  count = lower(var.cicd_system) == "azuredevops" ? 1 : 0

  resource_group_name                = try(azurerm_resource_group.rg[0].name, data.azurerm_resource_group.rg[0].name)
  resource_group_location            = try(azurerm_resource_group.rg[0].location, data.azurerm_resource_group.rg[0].location)
  name                               = var.name
  azp_pool_name                      = var.azp_pool_name
  azp_url                            = var.azp_url
  placeholder_agent_name             = var.placeholder_agent_name
  placeholder_container_name         = var.placeholder_container_name
  placeholder_replica_retry_limit    = var.placeholder_replica_retry_limit
  placeholder_replica_timeout        = var.placeholder_replica_timeout
  pat_token_secret_url               = var.pat_token_secret_url
  pat_token_value                    = var.pat_token_value
  polling_interval_seconds           = var.polling_interval_seconds
  runner_agent_cpu                   = var.runner_agent_cpu
  runner_agent_memory                = var.runner_agent_memory
  runner_container_name              = var.runner_container_name
  runner_replica_retry_limit         = var.runner_replica_retry_limit
  runner_replica_timeout             = var.runner_replica_timeout
  target_queue_length                = var.target_queue_length
  container_image_name               = var.container_image_name
  container_app_environment_name     = var.container_app_environment_name
  container_app_job_placeholder_name = var.container_app_job_placeholder_name
  container_app_job_runner_name      = var.container_app_job_runner_name
  min_execution_count                = var.min_execution_count
  max_execution_count                = var.max_execution_count
  subnet_id                          = try(azurerm_subnet.this_subnet[0].id, var.subnet_id)
  virtual_network_id                 = try(azurerm_virtual_network.this_vnet[0].id, data.azurerm_virtual_network.this_vnet[0].id)
  tracing_tags_enabled               = var.tracing_tags_enabled
  tracing_tags_prefix                = var.tracing_tags_prefix
  tags                               = var.tags
  lock                               = var.lock
  azure_container_registries         = var.azure_container_registries
  managed_identities                 = var.managed_identities
  key_vault_user_assigned_identity   = var.key_vault_user_assigned_identity
  role_assignments                   = var.role_assignments
  log_analytics_workspace_id         = try(azurerm_log_analytics_workspace.this_laws[0].id, var.log_analytics_workspace_id)
}

module "ca_github" {
  source = "./modules/ca-github-runners"

  count = lower(var.cicd_system) == "github" ? 1 : 0

  resource_group_name              = try(azurerm_resource_group.rg[0].name, data.azurerm_resource_group.rg[0].name)
  resource_group_location          = try(azurerm_resource_group.rg[0].location, data.azurerm_resource_group.rg[0].location)
  name                             = var.name
  github_keda_metadata             = var.github_keda_metadata
  pat_token_secret_url             = var.pat_token_secret_url
  pat_token_value                  = var.pat_token_value
  pat_env_var_name                 = var.pat_env_var_name
  environment_variables            = var.environment_variables
  polling_interval_seconds         = var.polling_interval_seconds
  runner_agent_cpu                 = var.runner_agent_cpu
  runner_agent_memory              = var.runner_agent_memory
  runner_container_name            = var.runner_container_name
  runner_replica_retry_limit       = var.runner_replica_retry_limit
  runner_replica_timeout           = var.runner_replica_timeout
  target_queue_length              = var.target_queue_length
  container_image_name             = var.container_image_name
  container_app_environment_name   = var.container_app_environment_name
  container_app_job_runner_name    = var.container_app_job_runner_name
  min_execution_count              = var.min_execution_count
  max_execution_count              = var.max_execution_count
  subnet_id                        = try(azurerm_subnet.this_subnet[0].id, var.subnet_id)
  virtual_network_id               = try(azurerm_virtual_network.this_vnet[0].id, data.azurerm_virtual_network.this_vnet[0].id)
  tracing_tags_enabled             = var.tracing_tags_enabled
  tracing_tags_prefix              = var.tracing_tags_prefix
  tags                             = var.tags
  lock                             = var.lock
  azure_container_registries       = var.azure_container_registries
  managed_identities               = var.managed_identities
  key_vault_user_assigned_identity = var.key_vault_user_assigned_identity
  role_assignments                 = var.role_assignments
  log_analytics_workspace_id       = try(azurerm_log_analytics_workspace.this_laws[0].id, var.log_analytics_workspace_id)
}