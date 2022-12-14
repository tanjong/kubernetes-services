variable "environment" {
  type        = string
  description = "Tier to be deployed eg test, dev, prod, etc"

  validation {
    condition     = lower(var.environment) == var.environment
    error_message = "Please use lower cases for tiers."
  }
}

variable "buildregion" {
  type        = string
  description = "Region(s) to deploy resources"

  validation {
    condition     = var.buildregion == "centralus" || var.buildregion == "centralus2"
    error_message = "Please deployments are only permitted to central or centralus2 azure regions."
  }
}

variable "subscriptionName" {
  type        = string
  description = "subscription to use"

  validation {
    condition     = var.subscriptionName == "dev_lab"
    error_message = "Please select dev_lab as your default subscription."
  }
}

/*****************
 * AKS VARIABLES *
 *****************/
variable "agent_count" {
  default = 5
}

variable "dns_prefix" {
  default = "k8stest"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}