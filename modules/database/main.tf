resource "azurerm_sql_server" "primary" {
    name = "sql-primary-database"
    resource_group_name = "my-sample-infra-rg"
    location = "Central India"
    version = "12.0"
    administrator_login = "sqladmin"
    administrator_login_password = "pa$$w0rd"
}

resource "azurerm_sql_database" "db" {
  name                = "db"
  resource_group_name = "my-sample-infra-rg"
  location            = "Central India"
  server_name         = azurerm_sql_server.primary.name
}

resource "azurerm_private_endpoint" "example" {
  name                = "mysql_backend_endpoint"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  subnet_id           = azurerm_subnet.app_db_connection_subnet.id

  private_service_connection {
    name                           = "mysql_privateserviceconnection"
    private_connection_resource_id = azurerm_sql_server.primary.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
}