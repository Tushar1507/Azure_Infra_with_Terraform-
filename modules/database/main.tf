resource "azurerm_mysql_server" "my_sql_server" {
  name                              = "mssqlserver"
  resource_group_name               = "my-sample-infra-rg"
  location                          = "Central India"
  version                           = "12.0"
  administrator_login               = "missadministrator"
  administrator_login_password      = "Password0123"
  minimum_tls_version               = "1.2"
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "00000000-0000-0000-0000-000000000000"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_mysql_database" "my_sql_db" {
  name                = "my_sql_db"
  resource_group_name = "my-sample-infra-rg"
  server_name         = azurerm_mysql_server.my_sql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "example" {
  name                = "mysql_backend_endpoint"
  location            = "Central India"
  resource_group_name = "my-sample-infra-rg"
  subnet_id           = azurerm_subnet.app_db_connection_subnet.id

  private_service_connection {
    name                           = "mysql_privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.my_sql_server.id
    subresource_names              = [ "mysqlServer" ]
    is_manual_connection           = false
  }
}