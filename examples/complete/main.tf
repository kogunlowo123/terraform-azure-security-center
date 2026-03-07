provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-security-complete"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-security-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 180
}

resource "azurerm_logic_app_workflow" "security_alerts" {
  name                = "logic-security-alerts"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_subscription" "current" {}

module "security_center" {
  source = "../../"

  security_contact_email               = "ciso@example.com"
  security_contact_phone               = "+15559876543"
  security_contact_alert_notifications = true
  security_contact_alerts_to_admins    = true

  auto_provisioning_enabled  = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  setting_mcas_enabled                = true
  setting_wdatp_enabled               = true
  setting_sentinel_onboarding_enabled = true

  defender_plans = {
    "vm" = {
      resource_type = "VirtualMachines"
      tier          = "Standard"
      subplan       = "P2"
    }
    "app-services" = {
      resource_type = "AppServices"
      tier          = "Standard"
    }
    "sql" = {
      resource_type = "SqlServers"
      tier          = "Standard"
    }
    "sql-vm" = {
      resource_type = "SqlServerVirtualMachines"
      tier          = "Standard"
    }
    "storage" = {
      resource_type = "StorageAccounts"
      tier          = "Standard"
      subplan       = "DefenderForStorageV2"
    }
    "keyvaults" = {
      resource_type = "KeyVaults"
      tier          = "Standard"
    }
    "containers" = {
      resource_type = "Containers"
      tier          = "Standard"
    }
    "arm" = {
      resource_type = "Arm"
      tier          = "Standard"
    }
    "dns" = {
      resource_type = "Dns"
      tier          = "Standard"
    }
    "oss-rdb" = {
      resource_type = "OpenSourceRelationalDatabases"
      tier          = "Standard"
    }
    "cosmos" = {
      resource_type = "CosmosDbs"
      tier          = "Standard"
    }
    "cspm" = {
      resource_type = "CloudPosture"
      tier          = "Standard"
    }
    "api" = {
      resource_type = "Api"
      tier          = "Standard"
    }
  }

  security_assessments = {
    "custom-encryption-check" = {
      display_name          = "Data Encryption at Rest Validation"
      description           = "Verify all data stores enforce encryption at rest with customer-managed keys"
      severity              = "High"
      categories            = ["Data"]
      implementation_effort = "Moderate"
      user_impact           = "Low"
      threats               = ["dataExfiltration", "dataSpillage"]
    }
    "custom-network-segmentation" = {
      display_name          = "Network Segmentation Check"
      description           = "Verify proper network segmentation between application tiers"
      severity              = "High"
      categories            = ["Networking"]
      implementation_effort = "High"
      user_impact           = "Moderate"
      threats               = ["elevationOfPrivilege", "lateralMovement"]
    }
    "custom-mfa-check" = {
      display_name          = "MFA Enforcement Verification"
      description           = "Ensure MFA is enforced for all administrative accounts"
      severity              = "High"
      categories            = ["IdentityAndAccess"]
      implementation_effort = "Low"
      user_impact           = "Moderate"
      threats               = ["accountBreach", "elevationOfPrivilege"]
    }
    "custom-logging-check" = {
      display_name          = "Centralized Logging Validation"
      description           = "Verify all resources send diagnostic logs to central workspace"
      severity              = "Medium"
      categories            = ["Compute"]
      implementation_effort = "Moderate"
      user_impact           = "Low"
      threats               = ["threatResistance"]
    }
  }

  security_automations = {
    "automation-high-severity" = {
      description         = "Forward high-severity alerts to Logic App"
      enabled             = true
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      scopes              = [data.azurerm_subscription.current.id]

      sources = [{
        event_source = "Alerts"
        rule_sets = [{
          rules = [{
            property_path  = "properties.metadata.severity"
            operator       = "Equals"
            expected_value = "High"
            property_type  = "String"
          }]
        }]
      }]

      actions = [{
        type        = "LogicApp"
        resource_id = azurerm_logic_app_workflow.security_alerts.id
        trigger_url = "https://placeholder-trigger-url"
      }]
    }

    "automation-regulatory-compliance" = {
      description         = "Forward compliance state changes"
      enabled             = true
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      scopes              = [data.azurerm_subscription.current.id]

      sources = [{
        event_source = "RegulatoryComplianceAssessment"
        rule_sets = [{
          rules = [{
            property_path  = "properties.status.code"
            operator       = "Equals"
            expected_value = "Failed"
            property_type  = "String"
          }]
        }]
      }]

      actions = [{
        type        = "LogicApp"
        resource_id = azurerm_logic_app_workflow.security_alerts.id
        trigger_url = "https://placeholder-trigger-url"
      }]
    }
  }

  tags = {
    Environment = "production"
    Project     = "security-platform"
    CostCenter  = "SEC-001"
    Compliance  = "SOC2"
  }
}

output "defender_plan_ids" {
  value = module.security_center.defender_plan_ids
}

output "defender_plan_details" {
  value = module.security_center.defender_plan_resource_types
}

output "workspace_assignment_id" {
  value = module.security_center.workspace_assignment_id
}

output "assessment_policy_ids" {
  value = module.security_center.assessment_policy_ids
}

output "automation_ids" {
  value = module.security_center.automation_ids
}

output "subscription_id" {
  value = module.security_center.subscription_id
}
