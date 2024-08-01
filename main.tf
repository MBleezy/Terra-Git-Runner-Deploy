data "azurerm_resource_group" "sandbox-rg" {
  name = "mbleezarde-sandbox"
}

#Create the vnet and subnet
resource "azurerm_virtual_network" "sandbox-vn" {
  name                = "git-runner-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name
  address_space       = ["10.123.0.0/16"]
}

resource "azurerm_subnet" "sandbox-sn" {
  name                 = "git-runner-subnet"
  resource_group_name  = data.azurerm_resource_group.sandbox-rg.name
  virtual_network_name = azurerm_virtual_network.sandbox-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

#Create the network security group
resource "azurerm_network_security_group" "sandbox-nsg" {
  name                = "git-runner-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name
}

resource "azurerm_network_security_rule" "sandbox-nsr" {
  name                        = "git-runner-nsr"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.sandbox-rg.name
  network_security_group_name = azurerm_network_security_group.sandbox-nsg.name

}

#Associate NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "sandbox-nsg-ass" {
  subnet_id                 = azurerm_subnet.sandbox-sn.id
  network_security_group_id = azurerm_network_security_group.sandbox-nsg.id
}

#Create the NIC
resource "azurerm_network_interface" "sandbox-nic" {
  name                = "git-runner-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sandbox-sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the NIC
resource "azurerm_network_interface_security_group_association" "sandbox-nic-ass" {
  network_interface_id      = azurerm_network_interface.sandbox-nic.id
  network_security_group_id = azurerm_network_security_group.sandbox-nsg.id
}

#Create the VM
resource "azurerm_linux_virtual_machine" "sandbox-Lvm" {
  name                            = "github-runner"
  resource_group_name             = data.azurerm_resource_group.sandbox-rg.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = var.adminpass
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.sandbox-nic.id,
  ]

  custom_data = filebase64("customdata.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

