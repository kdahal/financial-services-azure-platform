# APIM Gateway with TLS/OAuth/SAML
variable "resource_group_name" {}
variable "location" {}
variable "aks_id" {}
variable "kv_id" {}

resource "azurerm_api_management" "apim" {
  name                = "apim-smbc-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "SMBC Financial Platform"
  publisher_email     = "devops@smbc.co.jp"

  sku_name = "Developer_1"  # Scale to Premium for prod

  identity {
    type = "SystemAssigned"
  }

  # TLS/SSL Custom Domain (fetch cert from Key Vault)
  hostname_configuration {
    custom_https_port = 443
  }

  # OAuth/OpenID Policy
  policy {
    xml_content = <<XML
    <policies>
      <inbound>
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
          <openid-config url="https://login.microsoftonline.com/{tenant_id}/v2.0/.well-known/openid-configuration" />
          <audiences>
            <audience>${azurerm_api_management_api.sample_api.id}</audience>
          </audiences>
        </validate-jwt>
        <choose>
          <when condition="@(context.Request.Headers.GetValueOrDefault("saml-assertion", "").AsXml() != null)">
            <validate-saml header-name="saml-assertion" />
          </when>
        </choose>
        <set-backend-service base-url="https://${module.aks.load_balancer_ip}" />
      </inbound>
    </policies>
    XML
  }

  depends_on = [var.kv_id]  # Ensure certs are available
}

# Sample API
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

# WAF Policy for Risk Mitigation
resource "azurerm_api_management_policy" "waf" {
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  policy_name         = "global-waf-policy"

  xml_content = <<XML
  <policies>
    <inbound>
      <ip-filter action="block">
        <address>192.168.1.0/24</address>  <!-- Example deny list -->
      </ip-filter>
      <rate-limit calls="100" renewal-period="60" />
    </inbound>
  </policies>
  XML
}

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}