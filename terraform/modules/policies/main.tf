resource "azurerm_resource_group_policy_assignment" "encrypt_storage" {
  name                 = "encrypt-storage-policy"
  resource_group_id    = var.scope  # RG ID
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25"
  description          = "Enforce storage encryption with customer-managed keys"
}

resource "azurerm_resource_group_policy_assignment" "tls_enforcement" {
  name                 = "tls-enforcement-policy"
  resource_group_id    = var.scope  # RG ID
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/fe83a0eb-a853-422d-aac2-1bffd182c5d0"
  description          = "Enforce minimum TLS version 1.2 for storage accounts"
}