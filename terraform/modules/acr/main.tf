resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  tags = {
    Environment = var.environment
  }
}

output "login_server" {
  value = azurerm_container_registry.acr.login_server
}