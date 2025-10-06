variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment suffix"
  type        = string
}

variable "aks_id" {
  description = "AKS cluster ID"
  type        = string
}

variable "kv_id" {
  description = "Key Vault ID"
  type        = string
}

variable "apim_name" {
  description = "APIM instance name"
  type        = string
}

variable "apim_sku" {
  description = "APIM SKU"
  type        = string
  default     = "Developer_1"
}

variable "publisher_name" {
  description = "APIM publisher name"
  type        = string
}

variable "publisher_email" {
  description = "APIM publisher email"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "backend_url" {
  description = "Backend service URL for APIM policy"
  type        = string
  default     = "https://example.com"
}