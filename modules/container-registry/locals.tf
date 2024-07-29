locals {
    private_dns_zone_id = var.create_private_dns_zone ? azurerm_private_dns_zone.this[0].id : var.private_dns_zone_id
}