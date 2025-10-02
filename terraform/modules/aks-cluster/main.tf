variable "resource_group_name" {}
variable "location" {}
variable "kv_id" {}
variable "subnet_id" { default = "" }  # Assume from VNet module

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-smbc"

  default_node_pool {
    name       = "default"
    node_count = 1  # Scale for dev
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count  = 1
    max_count  = 3
  }

  identity {
    type = "SystemAssigned"
  }

  # OIDC for GitHub Actions
  kubelet_config {
    oidc_issuer_url = "https://sts.googleapis.com"  # Placeholder; use Azure OIDC
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  # Monitoring
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id  # Assume created
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