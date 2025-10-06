variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "kv_id" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "node_count" {
  type    = number
  default = 1
}

variable "vm_size" {
  type    = string
  default = "Standard_D2_v2"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-smbc"

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    enable_auto_scaling = true
    min_count      = 1
    max_count      = 3
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  }

  depends_on = [var.kv_id]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}