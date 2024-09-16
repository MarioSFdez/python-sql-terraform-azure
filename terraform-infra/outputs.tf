output "linux_web_app" {
  value = resource.azurerm_linux_web_app.web_app.name
}

output "url" {
  value = "${azurerm_linux_web_app.web_app.name}.azurewebsites.net"
}
