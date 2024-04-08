resource "azurerm_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_windows_web_app" "frontwebapp" {
  name                = "my_frontend_web_app"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  service_plan_id = azurerm_service_plan.appserviceplan.id

  site_config {}
  app_settings = {
    "WEBSITE_DNS_SERVER": "168.63.129.16",
    "WEBSITE_VNET_ROUTE_ALL": "1"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_windows_web_app.frontwebapp.id
  subnet_id       = azurerm_subnet.web_integrationsubnet.id
}

resource "azurerm_windows_web_app" "backwebapp" {
  name                = "my_backend_web_app"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  service_plan_id = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false

  site_config {}
}

resource "azurerm_private_dns_zone" "dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = "my-sample-infra-rg"
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name = "dnszonelink"
  resource_group_name = "my-sample-infra-rg"
  private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "backwebappprivateendpoint"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  subnet_id           = azurerm_subnet.web_app_connection_subnet.id

  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  }

  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_windows_web_app.backwebapp.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}