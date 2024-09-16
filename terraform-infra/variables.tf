variable "resource_group_name" {
  description = "Nombre del Grupo de Recursos"
  default     = "<resource-group-name>"
}

variable "app_service_name" {
  description = "Nombre del plan de servicios"
  default     = "<app-service-plan-name>"
}

variable "web_app_name" {
  description = "Nombre de la aplicación web"
  default     = "<web-app-name>"
}

variable "sql_server_name" {
  description = "Nombre del Servidor SQL"
  default     = "<sql-server-name>"
}

variable "admin_user" {
  description = "Nombre del usuario administrador"
  default     = "<admin-username>"
}

variable "admin_password" {
  description = "Contraseña del usuario administrador"
  default     = "<admin-password>"
}

variable "firewall_rule_name" {
  description = "Nombre de la Regla de Acceso al Servidor SQL"
  default     = "<firewall-rule-name>"
}

variable "ip_cliente" {
  description = "IPv4 del cliente para el acceso al Servidor SQL"
  default     = "<client-ip-address>"
}

variable "bbdd_name" {
  description = "Nombre de la base de datos"
  default     = "<database-name>"
}
