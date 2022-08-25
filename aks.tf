/*********************
 * SERVICE PRINCIPAL *
 *********************/

resource "azuread_application" "devlab-aksdemo" {
  display_name = "devlab-aksdemo"
}

resource "azuread_service_principal" "devlab-aksdemo" {
  application_id = azuread_application.devlab-aksdemo.application_id
}

resource "azuread_service_principal_password" "devlab-aksdemo" {
  service_principal_id = azuread_service_principal.devlab-aksdemo.id
}



/**********************
 * ANALYTIC WORKSPACE *
 **********************/
resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "devlab-clusterdemo-analytics-wsp" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = local.log_analytics_workspace_location
  resource_group_name = local.azurekubernetesrg
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "devlab-demoAnalytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.devlab-clusterdemo-analytics-wsp.location
  resource_group_name   = local.azurekubernetesrg
  workspace_resource_id = azurerm_log_analytics_workspace.devlab-clusterdemo-analytics-wsp.id
  workspace_name        = azurerm_log_analytics_workspace.devlab-clusterdemo-analytics-wsp.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

/******************
 * RESOURCE GROUP *
 ******************/
resource "azurerm_resource_group" "devlab-clusterdemo-rg" {
  name     = local.azurekubernetesrg
  location = local.buildregion
}


/*******
 * AKS *
 *******/
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cluster_name
  location            = local.buildregion
  resource_group_name = local.azurekubernetesrg
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCQcELFVK5XRFC+G5oMOjdF8+vHNUwjR5Eo8QWUfUXtORmgG0M9pzp2RoiIsMjTTs1UnhVWZQMXYvQVCLTOyZymb5VQd16c6SZD/n2PD6qBExXcQ8w3esUrP82N/oqCZvjQ0dVBvYIq5Xiw/uXEiTsRfV09kbsS3X8uQmvIdub8E3QNFn8noQ/pdsHQqsYBLx3Wa3/Ox93IFwTNz6zUhllrJfp2eHs0oegsaxMqR03K5ETyBAlDYE70eQOujirVTi0jvjAcpoLiUAyBb/ngIh3rtcJKzFG99gUTBKr+4tH+ZkdQsNswSRtytvilE6qfc/VLXZUHCggZ+rsafxLmwbWnyraCPMnHHm1l+qsbBF0quMUo2Ne3aahQgjeEGeMAax8avlC3hzEeUtJnmNRHnE3w3eHA5wZxh4r0Dv7+yWC1vy6c4bLFJXg3Gmn1J56QUlp4jLaHh+0ZHPztkZZHhCMDy8nWsblvfBowLOtJxm8p5EBVyTsFMXBIUZM85MjvEHYuEFuKq28BLXowOY+9L902cZxRmoUTqtRz0bxYzXWtrl9be1BWnxjYGKzaw6diudU0EL8N6opB7q8uuWLQYGzUcTCp29e3/48j4d2oADq/HXb3/E7ii814gb7inLPqd3hdtsqPK4WsdrO4Dcsvoyk3nybdHoHjBH5SQs+lm6Fgw== njiet@LAPTOP-KAMNFCIU"
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = azuread_service_principal.devlab-aksdemo.application_id
    client_secret = azuread_service_principal_password.devlab-aksdemo.value
  }

    # addon_profile {
    #   oms_agent {
    #     enabled                    = true
    #     log_analytics_workspace_id = azurerm_log_analytics_workspace.devlab-demoAnalytics.id
    #   }
    # }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = local.common_tags
}

/*************
 * NAMESPACE *
 *************/
# Create Namespace
resource "kubernetes_namespace" "devlab-clusterdemo" {
  metadata {
    annotations = {
      name = "devlab-clusterdemo"
    }

    labels = {
      mylabel = "devlab-clusterdemo"
    }

    name = "devlab-clusterdemo"
  }
}


