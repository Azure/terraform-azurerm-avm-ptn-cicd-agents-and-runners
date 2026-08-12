module "user_assigned_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.1"
  count   = var.user_assigned_managed_identity_creation_enabled ? 1 : 0

  location            = var.location
  name                = local.user_assigned_managed_identity_name
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

# When the caller brings their own UAMI we look up the client_id and
# principal_id from the resource_id, so they only have to pass one input
# instead of three correlated values they have to keep in sync.
data "azapi_resource" "user_assigned_managed_identity" {
  count = var.user_assigned_managed_identity_creation_enabled ? 0 : 1

  resource_id            = var.user_assigned_managed_identity_id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  response_export_values = ["properties.clientId", "properties.principalId"]
}
