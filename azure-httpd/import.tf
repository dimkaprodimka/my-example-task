#resource "random_string" "rg_name" {
#  prefix = var.resource_group_name_prefix
#}


# Create resource group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}${var.resource_group_name}"
}


#resource "azurerm_resource_group" "rg" {
#  location = var.resource_group_location
#  name     = var.resource_group_name
#}
