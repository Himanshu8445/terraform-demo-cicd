variable "keyvaults" {
  type = map(object({
    keyvault_name                 = string
    location                      = string
    resource_group_name           = string
    kv_sku_name                   = string
    purge_protection              = bool
    public_network_access_enabled = bool
  }))
}

variable "kv_additional_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

#########################
# Key Vault Access Policy
#########################
variable "access_policies" {
  type = map(object({
    group_names             = list(string)
    keyvault_name           = string
    object_id               = string
    user_principal_names    = list(string)
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
  description = "A map of access policies for the Key Vault"
  default     = {}
}

variable "msi_object_id" {
  type        = string
  description = "The object id of the MSI used by the ADO agent"
  default     = null
}

########################
# Key Vault Serets
########################
variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault"
  default     = {}
}