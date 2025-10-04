data "azurerm_client_config" "current" {}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.apim_sku

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend>
        <forward-request />
      </backend>
      <outbound />
      <on-error />
    </policies>
    XML
  }

  tags = var.tags
}

resource "azurerm_api_management_api" "sample_api" {
  name                = "${var.apim_name}-sample-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Sample API"
  path                = "treasury"
  protocols           = ["https"]
}

resource "azurerm_api_management_policy" "waf" {
  api_management_id = azurerm_api_management.apim.id
  policy_id         = "global-waf-policy"
  xml_content       = <<XML
<policies>
  <inbound>
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
      <openid-config url="https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration" />
      <audiences>
        <audience>${azurerm_api_management_api.sample_api.id}</audience>
      </audiences>
    </validate-jwt>
  </inbound>
  <backend>
    <forward-request />
  </backend>
</policies>
XML
}