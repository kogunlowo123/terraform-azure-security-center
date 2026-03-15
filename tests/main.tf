module "test" {
  source = "../"

  security_contact_email              = "security@example.com"
  security_contact_alert_notifications = true
  security_contact_alerts_to_admins   = true

  defender_plans = {
    virtual-machines = {
      resource_type = "VirtualMachines"
      tier          = "Standard"
    }
    storage = {
      resource_type = "StorageAccounts"
      tier          = "Standard"
    }
    key-vaults = {
      resource_type = "KeyVaults"
      tier          = "Standard"
    }
  }

  auto_provisioning_enabled = true

  setting_mcas_enabled  = true
  setting_wdatp_enabled = true

  enable_server_vulnerability_assessment      = false
  server_vulnerability_assessment_provider    = "mdeTvm"
  setting_sentinel_onboarding_enabled         = false

  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}
