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

/*
resource "azurerm_api_management_policy" "waf" {
  api_management_id = azurerm_api_management.apim.id

  policy_xml = <<XML
  <policies>
    <inbound>
      <base />
      <set-backend-service base-url="${var.backend_url}" />
      <choose>
        <when condition="@(context.Request.Url.Host.Contains('api.example.com'))">
          <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration" />
            <required-claims>
              <claim name="aud" match="any">
                <value>api://default</value>
              </claim>
            </required-claims>
          </validate-jwt>
        </when>
      </choose>
    </inbound>
    <backend>
      <base />
    </backend>
    <outbound>
      <base />
    </outbound>
    <on-error>
      <base />
    </on-error>
  </policies>
XML
}
*/

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}