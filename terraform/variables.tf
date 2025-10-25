variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "acr_name" {
  description = "ACR name"
  type        = string
}

variable "apim_name" {
  description = "APIM name"
  type        = string
}

variable "apim_sku" {
  description = "APIM SKU"
  type        = string
  default     = "Developer"
}

variable "publisher_name" {
  description = "APIM publisher name"
  type        = string
  default     = "Financial Services Co."
}

variable "publisher_email" {
  description = "APIM publisher email"
  type        = string
  default     = "admin@financial.com"
}

variable "node_count" {
  description = "AKS node count"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "AKS VM size"
  type        = string
  default     = "Standard_D2_v2"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "enable_free_tier" {
  description = "Enable free tier for Cosmos DB"
  type        = bool
  default     = true
}

variable "backend_url" {
  description = "Backend URL for APIM policy"
  type        = string
  default     = "https://example.com"
}

variable "object_id" {
  description = "Azure AD object ID for Key Vault access"
  type        = string
}