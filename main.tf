provider "azurerm" {
  features {}
}

module "resourcegroup" {
  source         = "./modules/resourcegroup"

}

module "networking" {
  source         = "./modules/networking"
  
}

module "compute" {
  source         = "./modules/compute"
}

module "database" {
  source = "./modules/database"
}
