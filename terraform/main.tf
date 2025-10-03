terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate${SUFFIX}"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"  # Use 'prod' for prod.tfvars
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = var.environment
    Owner       = "DevOps Team"
  }
}

# VNet Stub (for AKS subnet; expand as needed)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-smbc-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Key Vault Module (first, for secrets)
module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
}

# Cosmos DB Module
module "cosmos_db" {
  source              = "./modules/cosmos-db"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  kv_id               = module.key_vault.vault_id
}

# AKS Cluster Module
module "aks" {
  source              = "./modules/aks-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  kv_id               = module.key_vault.vault_id
  subnet_id           = azurerm_subnet.subnet.id
}

# APIM Module
module "apim" {
  source              = "./modules/apim-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  aks_id              = module.aks.cluster_id
  kv_id               = module.key_vault.vault_id
}

# Governance Policies
module "policies" {
  source = "./modules/policies"
  scope  = azurerm_resource_group.main.id
}