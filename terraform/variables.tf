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

variable "kv_id" {
  description = "Key Vault ID for secrets injection"
  type        = string
  default     = ""
}