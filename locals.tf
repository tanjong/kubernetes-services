locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service     = "devOps"
    Owner       = "dev_lab"
    environment = var.environment
    ManagedWith = "terraform"
  }

  buildregion      = var.buildregion
  subscriptionName = var.subscriptionName
}