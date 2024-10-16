resource "azurerm_resource_group" "resource_group" {
  name     = "terraform-rg"
  location = "Central US"
}

resource "azurerm_data_factory" "data_factory" {
  name                   = "terraform-adf"
  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = azurerm_resource_group.resource_group.location
  public_network_enabled = true
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "linked_service_blob" {
  name            = "linked-service-blob"
  data_factory_id = azurerm_data_factory.data_factory.id
}

resource "azurerm_data_factory_linked_service_web" "linked_service_dogs" {
  data_factory_id     = azurerm_data_factory.data_factory.id
  name                = "linked-service-dogs"
  url                 = "https://dog.ceo/"
  authentication_type = "Anonymous"
}

resource "azurerm_data_factory_pipeline" "pipeline" {
  name            = "pipeline"
  data_factory_id = azurerm_data_factory.data_factory.id
  activities_json = templatefile("pipeline.json", {})
}
