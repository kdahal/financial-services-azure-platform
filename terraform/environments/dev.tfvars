# Environment-specific variables for dev
environment      = "dev"
location         = "East US"
resource_group_name = "rg-financial-dev"

# Azure AD details
tenant_id        = "your-tenant-id-here"  # From az account show --query tenantId -o tsv
object_id        = "your-object-id-here"  # From az ad signed-in-user show --query id -o tsv

# AKS settings
node_count       = 1
vm_size          = "Standard_B2s"

# APIM settings
apim_sku = "Developer_1"
publisher_name   = "Contoso Financial"
publisher_email  = "admin@contoso.com"
backend_url      = "http://your-backend-url"  # Update post-apply with AKS IP

# Cosmos DB
enable_free_tier = true

# Names (required without defaults)
acr_name         = "acrsmbcdev"  # Ensure unique
apim_name        = "apim-smbc-dev"