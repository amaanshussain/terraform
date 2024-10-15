resource "azurerm_resource_group" "resource_group" {
  name     = "terraform-rg"
  location = "Central US"
}

resource "azurerm_container_registry" "container_registry" {
  name                = "terraformamaansacr"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Basic"
}

resource "azurerm_service_plan" "appservice_plan" {
  name                = "terraform-asp"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = "terraform-linux-webapp"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  service_plan_id     = azurerm_service_plan.appservice_plan.id

  site_config {
    container_registry_use_managed_identity = true
    application_stack {
        docker_registry_url = "https://${azurerm_container_registry.container_registry.login_server}"
        docker_image_name = "nginx:1.0.0"
    }
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "container_auth" {
  scope                = azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.linux_webapp.identity[0].principal_id
}