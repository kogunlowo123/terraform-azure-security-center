provider "azurerm" {
  features {}
}

module "security_center" {
  source = "../../"

  security_contact_email               = "security@example.com"
  security_contact_alert_notifications = true
  security_contact_alerts_to_admins    = true

  defender_plans = {
    "vm" = {
      resource_type = "VirtualMachines"
      tier          = "Standard"
    }
    "storage" = {
      resource_type = "StorageAccounts"
      tier          = "Standard"
    }
  }

  tags = {
    Environment = "development"
  }
}

output "defender_plan_ids" {
  value = module.security_center.defender_plan_ids
}
