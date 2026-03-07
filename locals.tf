locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-security-center"
  })

  alert_notifications_state = var.security_contact_alert_notifications ? "On" : "Off"
  alerts_to_admins_state    = var.security_contact_alerts_to_admins ? "On" : "Off"

  auto_provisioning_state = var.auto_provisioning_enabled ? "On" : "Off"

  workspace_scope = var.workspace_scope != null ? var.workspace_scope : data.azurerm_subscription.current.id

  defender_plans_map = {
    for k, v in var.defender_plans : v.resource_type => {
      key      = k
      tier     = v.tier
      subplan  = v.subplan
    }
  }

  integration_settings = {
    MCAS  = var.setting_mcas_enabled
    WDATP = var.setting_wdatp_enabled
  }
}
