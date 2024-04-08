############### App service Plan for web Apps #################
resource "azurerm_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  os_type             = "Windows"
  sku_name            = "P1v2"
}

############## Web App for frontend ###################
resource "azurerm_windows_web_app" "frontwebapp" {
  name                = "my_frontend_web_app"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  service_plan_id = azurerm_service_plan.appserviceplan.id

  site_config {}
}

######################## Web App Vnet integration ###################
resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_windows_web_app.frontwebapp.id
  subnet_id       = azurerm_subnet.web_integrationsubnet.id
}


###### public IP for App Gateway ###############
resource "azurerm_public_ip" "public_ip" {
  name                = "myAGPublicIPAddress"
  resource_group_name = "my-sample-infra-rg"
  location            = "Central India"
  allocation_method   = "Static"
  sku                 = "Standard"
}

####### App Gateway Resource ###################
resource "azurerm_application_gateway" "main" {
  name                = "myAppGateway"
  resource_group_name = "my-sample-infra-rg"
  location            = "Central India"
  depends_on = [ azurerm_windows_web_app.frontwebapp ]

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.AG_subnet.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
    fqdns = azurerm_windows_web_app.frontwebapp.default_hostname
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 1
  }
}

################# backend Web App #########################
resource "azurerm_windows_web_app" "backwebapp" {
  name                = "my_backend_web_app"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  service_plan_id = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false

  site_config {}
}

######### private DNS zone to define custom DNS and link to Vnet #########
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

########### private endpoint for connecting backend to frontend  ##############
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