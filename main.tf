resource "azurerm_resource_group" "this" {
  count = var.resource_group_creation_enabled ? 1 : 0

  location = var.location
  name     = var.resource_group_name == null ? "rg-${var.postfix}" : var.resource_group_name
}
