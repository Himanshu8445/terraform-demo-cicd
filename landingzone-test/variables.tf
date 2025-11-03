# - Resource Group
variable "resource_groups" {
  description = "Resource groups"
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  default = {}
}

##Storage Account

variable "storage_accounts" {
  type = map(object({
    name                            = string
    sku                             = string
    resource_group_name             = string
    location                        = string
    is_hns_enabled                  = bool
    public_network_access_enabled   = bool
    allow_nested_items_to_be_public = bool
    network_rules = object({
      bypass                     = list(string) # (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None.
      default_action             = string       # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
      ip_rules                   = list(string) # (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
      virtual_network_subnet_ids = list(string) # (Optional) One or more Subnet ID's which should be able to access this Key Vault.
    })
  }))
  description = "Map of storage accouts which needs to be created in a resource group"
  default     = {}
}

# variable "containers" {
#   type = map(object({
#     name                  = string
#     storage_account_name  = string
#     container_access_type = string
#   }))
#   description = "Map of Storage Containers"
#   default     = {}
# }

variable "sa_additional_tags" {
  type        = map(string)
  description = "Tags of the SA in addition to the resource group tag."
}