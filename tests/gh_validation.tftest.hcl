mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg"
      name = "my-rg"
    }
  }
  mock_data "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    }
  }
}

mock_provider "azapi" {}

run "no_suitable_key_vault_identity" {
  command = plan

  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    github_keda_metadata = {
      owner       = "Azure"
      runnerScope = "repo"
      repos       = join(",", ["terraform-azurerm-avm-ptn-cicd-agents-and-runners"])
    }
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "image"
    container_app_environment_name     = "ca"
    container_app_job_runner_name      = "runner"
    min_execution_count                = 1
    max_execution_count                = 1
    subnet_id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-snet"
    virtual_network_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    tracing_tags_enabled               = false
    tracing_tags_prefix                = ""
    tags                               = {}
    lock                               = {}
    azure_container_registries         = []
    environment_variables              = []
    managed_identities = {
      system_assigned            = false
      user_assigned_resource_ids = []
    }
    key_vault_user_assigned_identity = null
    role_assignments                 = {}
    log_analytics_workspace_id       = null
  }

  module {
    source = "./modules/ca-github-runners"
  }

  expect_failures = [
    azapi_resource.runner_job
  ]
}

run "implicit_key_vault_identity" {
  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    github_keda_metadata = {
      owner       = "Azure"
      runnerScope = "repo"
      repos       = join(",", ["terraform-azurerm-avm-ptn-cicd-agents-and-runners"])
    }
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "image"
    container_app_environment_name     = "ca"
    container_app_job_runner_name      = "runner"
    min_execution_count                = 1
    max_execution_count                = 1
    subnet_id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-snet"
    virtual_network_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    tracing_tags_enabled               = false
    tracing_tags_prefix                = ""
    tags                               = {}
    lock                               = {}
    azure_container_registries         = []
    environment_variables              = []
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
    key_vault_user_assigned_identity = null
    role_assignments                 = {}
    log_analytics_workspace_id       = null
  }

  module {
    source = "./modules/ca-github-runners"
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.secrets[0].identity == "System"
    error_message = "Expected PAT secret to use System identity for accessing KeyVault."
  }
}

run "explicit_key_vault_identity" {
  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    github_keda_metadata = {
      owner       = "Azure"
      runnerScope = "repo"
      repos       = join(",", ["terraform-azurerm-avm-ptn-cicd-agents-and-runners"])
    }
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "image"
    container_app_environment_name     = "ca"
    container_app_job_runner_name      = "runner"
    min_execution_count                = 1
    max_execution_count                = 1
    subnet_id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-snet"
    virtual_network_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    tracing_tags_enabled               = false
    tracing_tags_prefix                = ""
    tags                               = {}
    lock                               = {}
    azure_container_registries         = []
    environment_variables              = []
    managed_identities = {
      system_assigned            = false
      user_assigned_resource_ids = []
    }
    key_vault_user_assigned_identity = "identity-id"
    role_assignments                 = {}
    log_analytics_workspace_id       = null
  }

  module {
    source = "./modules/ca-github-runners"
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.secrets[0].identity == "identity-id"
    error_message = "Expected PAT secret to use explicity identity for accessing KeyVault."
  }
}

run "runner_job_configuration" {
  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    github_keda_metadata = {
      owner       = "Azure"
      runnerScope = "repo"
      repos       = join(",", ["repo1", "repo2"])
    }
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "microsoftavm/github-runner:1.0.1"
    container_app_environment_name     = "ca"
    container_app_job_runner_name      = "runner"
    min_execution_count                = 1
    max_execution_count                = 1
    subnet_id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-snet"
    virtual_network_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    tracing_tags_enabled               = false
    tracing_tags_prefix                = ""
    tags                               = {}
    lock                               = {}
    azure_container_registries         = []
    environment_variables              = [{
      name = "my-custom-var"
      value = "my-value"
    }]
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
    key_vault_user_assigned_identity = null
    role_assignments                 = {}
    log_analytics_workspace_id       = null
  }

  module {
    source = "./modules/ca-github-runners"
  }

  # KEDA Scaling
  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].type == "github-runner"
    error_message = "KEDA scaling rule should be set to github-runner."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].metadata.owner == "Azure"
    error_message = "KEDA scaling rule metadata should have correct owner."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].metadata.runnerScope == "repo"
    error_message = "KEDA scaling rule metadata should have correct runnerScope."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].metadata.repos == "repo1,repo2"
    error_message = "KEDA scaling rule metadata should have correct repos."
  }

  # Container Template
  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[1].name == "GH_RUNNER_TOKEN"
    error_message = "Personal Access Token environment variable should have GH_RUNNER_TOKEN as the default name."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].image == "microsoftavm/github-runner:1.0.1"
    error_message = "Container should have the correct image."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[0].name == "my-custom-var" && jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[0].value == "my-value"
    error_message = "Custom environment variables must be configured correctly."
  }
}