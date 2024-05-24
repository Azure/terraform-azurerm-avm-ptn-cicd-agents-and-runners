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

run "azp_url_must_be_specified" {
  command = plan

  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    azp_pool_name                      = "ado-pool"
    azp_url                            = null
    placeholder_agent_name             = null
    placeholder_container_name         = null
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
    pat_token_secret_url               = null
    pat_token_value                    = "pat-token"
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "image"
    container_app_environment_name     = "ca"
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
  }

  expect_failures = [
    azapi_resource.runner_job
  ]
}

run "no_suitable_key_vault_identity" {
  command = plan

  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    azp_pool_name                      = "ado-pool"
    azp_url                            = "https://dev.azure.com/my-org"
    placeholder_agent_name             = null
    placeholder_container_name         = null
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
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
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
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
    azp_pool_name                      = "ado-pool"
    azp_url                            = "https://dev.azure.com/my-org"
    placeholder_agent_name             = null
    placeholder_container_name         = null
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
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
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
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
    azp_pool_name                      = "ado-pool"
    azp_url                            = "https://dev.azure.com/my-org"
    placeholder_agent_name             = null
    placeholder_container_name         = null
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
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
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
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
    azp_pool_name                      = "ca-adoagent-pool"
    azp_url                            = "https://dev.azure.com/my-org"
    placeholder_agent_name             = null
    placeholder_container_name         = null
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "microsoftavm/azure-devops-agent:1.1.0"
    container_app_environment_name     = "ca"
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
  }

  # KEDA Scaling
  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].type == "azure-pipelines"
    error_message = "KEDA scaling rule should be set to azure-pipelines."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.eventTriggerConfig.scale.rules[0].metadata.poolName == "ca-adoagent-pool"
    error_message = "KEDA scaling rule should be targetting correct pool."
  }

  # Container Template
  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[3].value == "ca-adoagent-pool"
    error_message = "Container environment variable 'AZP_POOL' should have the correct pool."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].image == "microsoftavm/azure-devops-agent:1.1.0"
    error_message = "Container should have the correct image."
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[0].name == "my-custom-var" && jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[0].value == "my-value"
    error_message = "Custom environment variables must be configured correctly."
  }
}

run "placeholder_job_configuration" {
  variables {
    resource_group_name                = "my-rg"
    resource_group_location            = "uksouth"
    name                               = "ado"
    azp_pool_name                      = "ca-adoagent-pool"
    azp_url                            = "https://dev.azure.com/my-org"
    placeholder_agent_name             = "placeholder-agent-name-123"
    placeholder_container_name         = "placeholder-container-name-123"
    placeholder_replica_retry_limit    = null
    placeholder_replica_timeout        = null
    pat_token_secret_url               = "https://keyvault.com/secret/my-pat"
    pat_token_value                    = null
    polling_interval_seconds           = 1
    runner_agent_cpu                   = 1
    runner_agent_memory                = 1
    runner_container_name              = "runner"
    runner_replica_retry_limit         = 1
    runner_replica_timeout             = 1
    target_queue_length                = 1
    container_image_name               = "microsoftavm/azure-devops-agent:1.1.0"
    container_app_environment_name     = "ca"
    container_app_job_placeholder_name = "placeholder"
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
    source = "./modules/ca-azure-devops-agents"
  }

  # KEDA Scaling
  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.configuration.triggerType == "Manual"
    error_message = "Scaling trigger type should be 'Manual' for placeholder agent."
  }

  # Container Template
  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].env[3].value == "ca-adoagent-pool"
    error_message = "Container environment variable 'AZP_POOL' should have the correct pool."
  }

  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].env[4].value == "1"
    error_message = "Container environment variable 'AZP_PLACEHOLDER' should be '1'."
  }

  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].env[5].value == "placeholder-agent-name-123"
    error_message = "Container environment variable 'AZP_AGENT_NAME' should be 'placeholder-agent-name-123'."
  }

  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].name == "placeholder-container-name-123"
    error_message = "Container should have the correct name."
  }

  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].image == "microsoftavm/azure-devops-agent:1.1.0"
    error_message = "Container should have the correct image."
  }

  assert {
    condition     = jsondecode(azapi_resource.placeholder_job.body).properties.template.containers[0].env[0].name == "my-custom-var" && jsondecode(azapi_resource.runner_job.body).properties.template.containers[0].env[0].value == "my-value"
    error_message = "Custom environment variables must be configured correctly."
  }
}