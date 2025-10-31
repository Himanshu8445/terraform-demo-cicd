output "keyvaults" {
  value = azurerm_key_vault.this
}

output "key_vault_policy" {
  description = "Key Vault access policy details"
  value       = azurerm_key_vault_access_policy.this
}

output "keyvault_id_map" {
  description = "Key Vault Name to ID MAP"
  value       = { for kv in azurerm_key_vault.this : kv.name => kv.id }
}