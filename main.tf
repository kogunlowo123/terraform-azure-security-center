data "azurerm_subscription" "current" {}

resource "azurerm_security_center_contact" "this" {
  email               = var.security_contact_email
  phone               = var.security_contact_phone
  alert_notifications = var.security_contact_alert_notifications
  alerts_to_admins    = var.security_contact_alerts_to_admins
}

resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = var.defender_plans

  tier          = each.value.tier
  resource_type = each.value.resource_type
  subplan       = each.value.subplan
}

resource "azurerm_security_center_auto_provisioning" "this" {
  auto_provision = var.auto_provisioning_enabled ? "On" : "Off"
}

resource "azurerm_security_center_workspace" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  scope        = var.workspace_scope != null ? var.workspace_scope : data.azurerm_subscription.current.id
  workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "this" {
  count = var.enable_server_vulnerability_assessment ? 1 : 0

  virtual_machine_id = ""
}

resource "azurerm_security_center_setting" "mcas" {
  setting_name = "MCAS"
  enabled      = var.setting_mcas_enabled
}

resource "azurerm_security_center_setting" "wdatp" {
  setting_name = "WDATP"
  enabled      = var.setting_wdatp_enabled
}

resource "azurerm_security_center_setting" "sentinel" {
  count = var.setting_sentinel_onboarding_enabled ? 1 : 0

  setting_name = "Sentinel"
  enabled      = var.setting_sentinel_onboarding_enabled
}

resource "azurerm_security_center_assessment_policy" "this" {
  for_each = var.security_assessments

  display_name          = each.value.display_name
  description           = each.value.description
  severity              = each.value.severity
  categories            = each.value.categories
  implementation_effort = each.value.implementation_effort
  user_impact           = each.value.user_impact
  threats               = each.value.threats
}

resource "azurerm_security_center_automation" "this" {
  for_each = var.security_automations

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  description         = each.value.description
  enabled             = each.value.enabled
  scopes              = each.value.scopes

  dynamic "source" {
    for_each = each.value.sources
    content {
      event_source = source.value.event_source

      dynamic "rule_set" {
        for_each = source.value.rule_sets
        content {
          dynamic "rule" {
            for_each = rule_set.value.rules
            content {
              property_path  = rule.value.property_path
              operator       = rule.value.operator
              expected_value = rule.value.expected_value
              property_type  = rule.value.property_type
            }
          }
        }
      }
    }
  }

  dynamic "action" {
    for_each = each.value.actions
    content {
      type        = action.value.type
      resource_id = action.value.resource_id
      trigger_url = action.value.trigger_url
    }
  }

  tags = merge(var.tags, each.value.tags)
}
