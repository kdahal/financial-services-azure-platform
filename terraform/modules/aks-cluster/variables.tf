variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment suffix (e.g., dev)"
  type        = string
  default     = "dev"
}

variable "kv_id" {
  description = "Key Vault ID for secrets injection"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of nodes in default pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2_v2"
}