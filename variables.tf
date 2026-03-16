variable "security_contact_email" {
  description = "Email address for security contact notifications."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.security_contact_email))
    error_message = "Must be a valid email address."
  }
}

variable "security_contact_phone" {
  description = "Phone number for security contact (optional)."
  type        = string
  default     = null
}

variable "security_contact_alert_notifications" {
  description = "Whether to send alert notifications to the security contact."
  type        = bool
  default     = true
}

variable "security_contact_alerts_to_admins" {
  description = "Whether to send alerts to subscription admins."
  type        = bool
  default     = true
}

variable "defender_plans" {
  description = "Map of Microsoft Defender for Cloud pricing tiers per resource type."
  type = map(object({
    tier          = optional(string, "Standard")
    subplan       = optional(string, null)
    resource_type = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.defender_plans : contains(["Free", "Standard"], v.tier)
    ])
    error_message = "Defender plan tier must be Free or Standard."
  }

  validation {
    condition = alltrue([
      for k, v in var.defender_plans : contains([
        "AppServices", "ContainerRegistry", "KeyVaults",
        "KubernetesService", "SqlServers", "SqlServerVirtualMachines",
        "StorageAccounts", "VirtualMachines", "Arm",
        "Dns", "OpenSourceRelationalDatabases", "Containers",
        "CosmosDbs", "CloudPosture", "Api"
      ], v.resource_type)
    ])
    error_message = "Resource type must be a valid Defender for Cloud resource type."
  }
}

variable "auto_provisioning_enabled" {
  description = "Whether auto-provisioning of the Log Analytics agent is enabled."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for Security Center data."
  type        = string
  default     = null
}

variable "workspace_scope" {
  description = "Scope for the workspace assignment (defaults to current subscription)."
  type        = string
  default     = null
}

variable "enable_server_vulnerability_assessment" {
  description = "Whether to enable server vulnerability assessment auto-provisioning."
  type        = bool
  default     = false
}

variable "server_vulnerability_assessment_provider" {
  description = "Vulnerability assessment provider: mdeTvm (Defender) or qualys."
  type        = string
  default     = "mdeTvm"

  validation {
    condition     = contains(["mdeTvm", "qualys"], var.server_vulnerability_assessment_provider)
    error_message = "Provider must be 'mdeTvm' or 'qualys'."
  }
}

variable "security_assessments" {
  description = "Map of custom security assessment policies to create."
  type = map(object({
    display_name          = string
    description           = string
    severity              = optional(string, "Medium")
    categories            = optional(list(string), ["Compute"])
    implementation_effort = optional(string, "Moderate")
    user_impact           = optional(string, "Moderate")
    threats               = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.security_assessments : contains(["High", "Medium", "Low"], v.severity)
    ])
    error_message = "Severity must be High, Medium, or Low."
  }
}

variable "security_automations" {
  description = "Map of Security Center automations for workflow triggers."
  type = map(object({
    description         = optional(string, "")
    enabled             = optional(bool, true)
    location            = string
    resource_group_name = string
    scopes              = list(string)

    sources = list(object({
      event_source = string
      rule_sets = optional(list(object({
        rules = list(object({
          property_path  = string
          operator       = string
          expected_value = string
          property_type  = string
        }))
      })), [])
    }))

    actions = list(object({
      type        = string
      resource_id = string
      trigger_url = optional(string, null)
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "setting_mcas_enabled" {
  description = "Whether to enable Microsoft Cloud App Security (MCAS) integration."
  type        = bool
  default     = true
}

variable "setting_wdatp_enabled" {
  description = "Whether to enable Windows Defender ATP (WDATP/MDE) integration."
  type        = bool
  default     = true
}

variable "setting_sentinel_onboarding_enabled" {
  description = "Whether to enable Sentinel onboarding."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
