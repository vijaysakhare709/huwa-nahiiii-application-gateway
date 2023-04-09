resource "azurerm_public_ip" "gateway-ip" {
  name                = "gateway-ip"
  resource_group_name = azurerm_resource_group.vijay.name
  location            = azurerm_resource_group.vijay.location
  allocation_method   = "Static"
  sku = "Standard"
  sku_tier = "Regional"
}

# we need an additional subnet in the virtual network

resource "azurerm_subnet" "appsubnet" {
  name                 = "appsubnet"
  resource_group_name  = azurerm_resource_group.vijay.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_application_gateway" "appgeteway" {
  name                = "app-vijay-geteway"
  resource_group_name = azurerm_resource_group.vijay.name
  location            = azurerm_resource_group.vijay.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard"
    capacity = 2
  }

 gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appsubnet.id
  }

  frontend_port {
    name = "frontend_port_name"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_configuration_appg"
    public_ip_address_id = azurerm_public_ip.gateway-ip.id
  }

depends_on = [
  azurerm_subnet.appsubnet
]

  backend_address_pool {
    name = "backend_address_pool_A"
    ip_addresses = [
        "${azurerm_network_interface.vijay-interfaced-1.private_ip_address}"
        ]
  }

 backend_http_settings {
    name                  = "HTTPsetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

   http_listener {
    name                           = "geteway-listener"
    frontend_ip_configuration_name = "frontend_ip_configuration_appg"
    frontend_port_name             = "frontend_port_name"
    protocol                       = "Http"
  }

    request_routing_rule {
    name                       = "RoutingRuleA"
    rule_type                  = "PathBasedRouting"
    url_path_map_name          = "RoutingPath"
    http_listener_name         = "geteway-listener"
    priority                   = 1
  }

}
