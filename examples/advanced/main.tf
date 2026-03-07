provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-security-advanced"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-security-advanced"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

data "azurerm_subscription" "current" {}

module "security_center" {
  source = "../../"

  security_contact_email               = "security-team@example.com"
  security_contact_phone               = "+15551234567"
  security_contact_alert_notifications = true
  security_contact_alerts_to_admins    = true

  auto_provisioning_enabled  = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  setting_mcas_enabled  = true
  setting_wdatp_enabled = true

  defender_plans = {
    "vm" = {
      resource_type = "VirtualMachines"
      tier          = "Standard"
      subplan       = "P2"
    }
    "sql" = {
      resource_type = "SqlServers"
      tier          = "Standard"
    }
    "app-services" = {
      resource_type = "AppServices"
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
    "arm" = {
      resource_type = "Arm"
      tier          = "Standard"
    }
    "dns" = {
      resource_type = "Dns"
      tier          = "Standard"
    }
  }

  security_assessments = {
    "custom-encryption-check" = {
      display_name          = "Data Encryption at Rest"
      description           = "Verify all data stores use encryption at rest"
      severity              = "High"
      categories            = ["Data"]
      implementation_effort = "Low"
      user_impact           = "Low"
      threats               = ["dataExfiltration", "dataSpillage"]
    }
  }

  tags = {
    Environment = "staging"
    Project     = "security-advanced"
  }
}

output "defender_plan_ids" {
  value = module.security_center.defender_plan_ids
}

output "workspace_assignment_id" {
  value = module.security_center.workspace_assignment_id
}
