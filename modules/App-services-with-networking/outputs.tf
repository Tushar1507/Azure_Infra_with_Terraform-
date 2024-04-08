output "hostname" {
  value       = azurerm_windows_web_app.frontwebapp.default_hostname
  description = "The default hostname of the web app."
}