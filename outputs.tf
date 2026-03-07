output "security_contact_id" {
  description = "Resource ID of the security contact."
  value       = azurerm_security_center_contact.this.id
}

output "defender_plan_ids" {
  description = "Map of Defender plan keys to their resource IDs."
  value       = { for k, v in azurerm_security_center_subscription_pricing.this : k => v.id }
}

output "defender_plan_resource_types" {
  description = "Map of Defender plan keys to their resource types and tiers."
  value = {
    for k, v in azurerm_security_center_subscription_pricing.this : k => {
      resource_type = v.resource_type
      tier          = v.tier
    }
  }
}

output "auto_provisioning_id" {
  description = "Resource ID of the auto-provisioning setting."
  value       = azurerm_security_center_auto_provisioning.this.id
}

output "auto_provisioning_state" {
  description = "Auto-provisioning state (On/Off)."
  value       = azurerm_security_center_auto_provisioning.this.auto_provision
}

output "workspace_assignment_id" {
  description = "Resource ID of the workspace assignment."
  value       = var.log_analytics_workspace_id != null ? azurerm_security_center_workspace.this[0].id : null
}

output "mcas_setting_enabled" {
  description = "Whether MCAS integration is enabled."
  value       = azurerm_security_center_setting.mcas.enabled
}

output "wdatp_setting_enabled" {
  description = "Whether WDATP/MDE integration is enabled."
  value       = azurerm_security_center_setting.wdatp.enabled
}

output "assessment_policy_ids" {
  description = "Map of custom assessment policy names to their resource IDs."
  value       = { for k, v in azurerm_security_center_assessment_policy.this : k => v.id }
}

output "assessment_policy_names" {
  description = "Map of custom assessment policy keys to their display names."
  value       = { for k, v in azurerm_security_center_assessment_policy.this : k => v.display_name }
}

output "automation_ids" {
  description = "Map of security automation names to their resource IDs."
  value       = { for k, v in azurerm_security_center_automation.this : k => v.id }
}

output "subscription_id" {
  description = "Subscription ID where Defender for Cloud is configured."
  value       = data.azurerm_subscription.current.subscription_id
}
