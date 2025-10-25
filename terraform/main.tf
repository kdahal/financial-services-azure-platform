terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  /*
  backend "azurerm" {
    resource_group_name = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name = "tfstate"
    key = "dev.terraform.tfstate" # Override key to "prod.terraform.tfstate" for prod deployments
  }
  */
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

# VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-smbc-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ACR Module
module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  acr_name            = var.acr_name
  environment         = var.environment
}

# Key Vault Module
module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

# Cosmos DB Module
module "cosmos_db" {
  source              = "./modules/cosmos-db"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  kv_id               = module.key_vault.vault_id
  enable_free_tier = var.enable_free_tier
}

# AKS Cluster Module
module "aks" {
  source              = "./modules/aks-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  kv_id               = module.key_vault.vault_id
  subnet_id           = azurerm_subnet.subnet.id
  node_count          = var.node_count
  vm_size             = var.vm_size
}

# APIM Module
module "apim" {
  source                = "./modules/apim-gateway"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  environment           = var.environment
  aks_id                = module.aks.cluster_id
  kv_id                 = module.key_vault.vault_id
  apim_name             = var.apim_name
  apim_sku              = var.apim_sku
  publisher_name        = var.publisher_name
  publisher_email       = var.publisher_email
  tenant_id             = var.tenant_id
  backend_url           = var.backend_url
}

# Governance Policies
module "policies" {
  source = "./modules/policies"
  scope  = azurerm_resource_group.main.id
}