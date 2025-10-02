variable "resource_group_name" {}
variable "location" {}
variable "environment" {}

resource "azurerm_key_vault" "kv" {
  name                = "kv-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete"
    ]
    key_permissions = [
      "Get", "List", "Create", "Delete"
    ]
  }
}

data "azurerm_client_config" "current" {}

# Sample secret for API (in prod, manage via CI/CD)
resource "azurerm_key_vault_secret" "api_secret" {
  name         = "jwt-secret"
  value        = "dev-secret-change-me"
  key_vault_id = azurerm_key_vault.kv.id
}

output "vault_id" {
  value = azurerm_key_vault.kv.id
}