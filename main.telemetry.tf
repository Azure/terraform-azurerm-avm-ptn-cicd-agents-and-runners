resource "random_id" "telem" {
  count = var.enable_telemetry ? 1 : 0

  byte_length = 4
}

# This is the module telemetry deployment that is only created if telemetry is enabled.
# It is deployed to the resource's resource group.
resource "azurerm_resource_group_template_deployment" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  deployment_mode     = "Incremental"
  name                = local.telem_arm_deployment_name
  resource_group_name = try(azurerm_resource_group.rg[0].name, data.azurerm_resource_group.rg[0].name)
  tags = (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "N/A"
    avm_git_file             = "main.telemetry.tf"
    avm_git_last_modified_at = "2024-04-03 14:02:00"
    avm_git_org              = "BlakeWills"
    avm_git_repo             = "terraform-azurerm-avm-ptn-cicd-agents-and-runners-ca"
    avm_yor_name             = "telemetry"
    avm_yor_trace            = "b6b385a2-e37a-47eb-ab7f-9f437bdc6f41"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/)
  template_content = local.telem_arm_template_content
}
