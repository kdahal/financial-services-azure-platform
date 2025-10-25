resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "cosmos-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  automatic_failover_enabled = true

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level = "Session"
  }

  free_tier_enabled = var.enable_free_tier

  identity {
    type = "SystemAssigned"
  }

  depends_on = [var.kv_id]
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "financial-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400
}

output "endpoint" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}