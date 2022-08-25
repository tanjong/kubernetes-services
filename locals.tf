locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service     = "devOps"
    Owner       = "dev_lab"
    environment = var.environment
    ManagedWith = "terraform"
  }

  buildregion                      = var.buildregion
  subscriptionName                 = var.subscriptionName
  acr                              = "devlab-democluster-acr"
  azurekubernetesrg                = "devlab-clusterdemo"
  cluster_name                     = "devlab-clusterdemo"
  log_analytics_workspace_location = "eastus"
  log_analytics_workspace_name     = "devlab-analytics-wsp"
}