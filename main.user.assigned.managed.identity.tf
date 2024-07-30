module "user_assigned_managed_identity" {
  count   = var.create_user_assigned_managed_identity ? 1 : 0
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.1"

  location            = var.location
  name                = local.user_assigned_managed_identity_name
  resource_group_name = local.resource_group_name
}