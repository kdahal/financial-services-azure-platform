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
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Variables
variable "location" { default = "East US" }
variable "environment" { default = "prod" }
variable "resource_group_name" { default = "rg-smbc-platform" }

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = var.environment
    Owner       = "DevOps Team"
  }
}

# Key Vault Module
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
  kv_id               = module.key_vault.vault_id  # Inject secrets
}

# AKS Cluster Module
module "aks" {
  source              = "./modules/aks-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  kv_id               = module.key_vault.vault_id
  subnet_id           = module.vnet.subnet_id  # Assume VNet module
}

# APIM Module with Security
module "apim" {
  source              = "./modules/apim-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  aks_id              = module.aks.cluster_id
  kv_id               = module.key_vault.vault_id
}

# Governance Policies
module "policies" {
  source              = "./modules/policies"
  scope               = azurerm_resource_group.main.id
}

# Outputs
output "aks_kubeconfig" {
  value     = module.aks.kubeconfig
  sensitive = true
}
output "apim_endpoint" {
  value = module.apim.gateway_url
}