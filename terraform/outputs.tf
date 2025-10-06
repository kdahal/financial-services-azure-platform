output "aks_kubeconfig" {
  description = "AKS kubeconfig"
  value       = module.aks.kubeconfig
  sensitive   = true
}

output "apim_endpoint" {
  description = "APIM gateway URL"
  value       = module.apim.gateway_url
}

output "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.cosmos_db.endpoint
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.key_vault.vault_id
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.login_server
}