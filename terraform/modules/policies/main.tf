variable "scope" {
  type = string
}

resource "azurerm_policy_assignment" "encrypt_storage" {
  name                 = "enforce-encryption"
  scope                = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/932d736c-0733-44f7-8f4a-8ec11b5a4ac0"
  description          = "Ensure storage accounts are encrypted for PCI DSS compliance"
  parameters = jsonencode({
    effect = "Deny"
  })
}

resource "azurerm_policy_assignment" "tls_enforcement" {
  name                 = "tls-1-3-minimum"
  scope                = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/061f9a79-0a52-4c9f-9e4e-93e0e7a637a9"
  parameters = jsonencode({
    effect = "Audit"
  })
}