resource "azurerm_windows_virtual_machine" "WebVM" {
  name = "WebVM"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.WebNic.id]
  admin_username = var.admin_username
  admin_password = var.admin_password

 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
}
 os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
 } 
}


resource "azurerm_windows_virtual_machine" "AppVM" {
  name = "AppVM"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.AppNic.id]
  admin_username = var.admin_username
  admin_password = var.admin_password

 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
}
 os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
 } 
}