resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb

    kubelet_config {
      cpu_manager_policy = "static"
      cpu_cfs_quota_enabled = true
    }

    addon_profile {
      oms_agent {
        enabled = var.enable_oms_agent
        log_analytics_workspace_id = var.log_analytics_workspace_id
      }
    }
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    pod_cidr          = var.pod_cidr
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}