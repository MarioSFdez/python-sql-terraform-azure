resource "azurerm_resource_group" "RG_mario" {
  name     = var.resource_group_name
  location = "spaincentral"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.RG_mario.name
  location            = azurerm_resource_group.RG_mario.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.RG_mario.location
  resource_group_name = azurerm_resource_group.RG_mario.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  https_only          = true

  site_config {
    application_stack {
      # Si falla la versión de python cambiar la version del proveedor hashicorp/azurerm con <terraform init -upgrade>
      python_version = "3.12"
    }
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "server"   = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    "database" = azurerm_mssql_database.bbdd_usuarios.name
    "user"     = var.admin_user
    "password" = var.admin_password
    SCM_DO_BUILD_DURING_DEPLOYMENT = 1
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.RG_mario.name
  location                     = azurerm_resource_group.RG_mario.location
  version                      = "12.0"
  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password
  minimum_tls_version          = "1.2"
}

# Agregar el siguiente recurso si queremos acceder al servidor SQL desde una dirección IP especifica
resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = var.ip_cliente
  end_ip_address   = var.ip_cliente
}

resource "azurerm_mssql_database" "bbdd_usuarios" {
  name        = var.bbdd_name
  server_id   = azurerm_mssql_server.sql_server.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name    = "Basic"

  storage_account_type = "Local"
}

