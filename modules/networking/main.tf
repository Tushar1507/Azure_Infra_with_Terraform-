resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "AG_subnet" {
  name                 = "ag_subnet"
  resource_group_name  = "my-sample-infra-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Network/applicationGateways"
    }
  }
}


resource "azurerm_subnet" "web_integrationsubnet" {
  name                 = "web_integrationsubnet"
  resource_group_name  = "my-sample-infra-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "web_app_connection_subnet" {
  name                 = "web_app_connection_subnet"
  resource_group_name  = "my-sample-infra-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "app_db_connection_subnet" {
  name                 = "app_db_connection_subnet"
  resource_group_name  = "my-sample-infra-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
  private_endpoint_network_policies_enabled = true
}