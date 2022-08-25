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

resource "azurerm_log_analytics_workspace" "devlab-analytics-wsp" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = local.log_analytics_workspace_location
  resource_group_name = local.azurekubernetesrg
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "devlab-demoAnalytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.devlab-demoAnalytics.location
  resource_group_name   = local.azurekubernetesrg
  workspace_resource_id = azurerm_log_analytics_workspace.devlab-demoAnalytics.id
  workspace_name        = azurerm_log_analytics_workspace.devlab-demoAnalytics.name

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
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyBPnWDA5kVE4Ks2n7hoX/COwpEuxuf+0be5O7B77q+gsz6irJN181IJ+Acc1qiJMRLatnAH4e5qgj4/oRKGnVIEnVtQVjxMsm2/PdOZ2eE9K3/lNO49JRaf1jmuKNS8nis25dGzLZT44B+PhyVlIp4qH3PFXuD1bcd2Bo7CXdB+z97rBR4m89/pWtf7thrp7babFAKofPn1On3HNfaFC4DaeQmlRiVBHYiS53ze3QMSQ8TKrgo6vRbvOQ2sDmOrNRqBVC1T4IXbxgu9ZMEoUNmYCXZGOgujGdkSCe1rlbeFFsjRdCbMj4LC9t1/KwOft0ZEztuptc8ayteRfXHptkMd9DVfvnKf5OqmTqXLiIsFLlyqOXJ6Frlx+W+67x2Ev+JiHuW9mYT8V/MX1mlXeQsY8P0/NYT7yK7happQ41ajuE3SmZ73kwYgewEX699WV/C5FkgNF1jM2dFlWC2l9ezSnhyqQ6W7XzUbXtukFT0nMoQmrEfyuiWCoRAFK7Ay1EFB4QcvjrcXAMe9QtjjjsZFvkT/iKskBJkN3Rxep3pSLvKqFtJiqjUJXzLZoEq9gI7aRBoPz0dxjEbOjzoCeRiB/ZSd+F5vLonv13qXcgXdnZGQ85TFceT4wQ75SwaFHyUAhXZX4bxqBOdt4ZL1/lAduB+oyOCXLhoMzFhRBrGQ== lbena@LAPTOP-QB0DU4OG"
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = azuread_service_principal.eliteclusterdemodev-SP.application_id
    client_secret = azuread_service_principal_password.eliteclusterdemodev-SP.value
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
resource "kubernetes_namespace" "eliteclusterdemo" {
  metadata {
    annotations = {
      name = "eliteclusterdemo"
    }

    labels = {
      mylabel = "eliteclusterdemo"
    }

    name = "eliteclusterdemo"
  }
}


