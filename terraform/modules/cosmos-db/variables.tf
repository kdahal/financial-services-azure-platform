variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment suffix"
  type        = string
}

variable "kv_id" {
  description = "Key Vault ID"
  type        = string
}

variable "enable_free_tier" {
  description = "Enable free tier for Cosmos DB"
  type        = bool
  default     = true
}