variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "aks_id" {
  type = string
}

variable "kv_id" {
  type = string
}

variable "apim_name" {
  type = string
}

variable "apim_sku" {
  type    = string
  default = "Developer_1"
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "backend_url" {
  type    = string
  default = "https://example.com"
}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.apim_sku

  identity {
    type = "SystemAssigned"
  }

  policy {
    xml_content = <<XML
    <policies>
      <inbound>
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
          <openid-config url="https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration" />
          <audiences>
            <audience>api://treasury-api</audience>
          </audiences>
        </validate-jwt>
        <set-backend-service base-url="${var.backend_url}" />
      </inbound>
    </policies>
    XML
  }

  depends_on = [var.kv_id]
}

resource "azurerm_api_management_api" "sample_api" {
  name                = "treasury-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Treasury Management API"
  description         = "Secure API for financial transactions"
  path                = "treasury"
  protocols           = ["https"]
}

resource "azurerm_api_management_policy" "waf" {
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  policy_name         = "global-waf-policy"
  xml_content = <<XML
  <policies>
    <inbound>
      <ip-filter action="block">
        <address>192.168.1.0/24</address>
      </ip-filter>
      <rate-limit calls="100" renewal-period="60" />
    </inbound>
  </policies>
  XML
}

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}