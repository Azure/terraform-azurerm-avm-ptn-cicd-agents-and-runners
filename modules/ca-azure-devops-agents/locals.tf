locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
}

# Use the explicit identity for each operation, or, use the SINGLE supplied identity. Fail if multiple, or no identities are supplied.
locals {
  key_vault_user_assigned_identity = var.key_vault_user_assigned_identity != null ? var.key_vault_user_assigned_identity : local.single_id
  single_id                        = (var.managed_identities.system_assigned != (length(var.managed_identities.user_assigned_resource_ids) == 1)) ? var.managed_identities.system_assigned ? "System" : tolist(var.managed_identities.user_assigned_resource_ids)[0] : null
}