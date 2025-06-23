module "user_assigned_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"
  count   = var.user_assigned_managed_identity_creation_enabled ? 1 : 0

  location            = var.location
  name                = local.user_assigned_managed_identity_name
  resource_group_name = local.resource_group_name
  tags                = var.tags
}