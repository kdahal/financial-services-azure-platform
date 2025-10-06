variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "acr_name" {
  description = "ACR name"
  type        = string
}

variable "environment" {
  description = "Environment suffix"
  type        = string
}