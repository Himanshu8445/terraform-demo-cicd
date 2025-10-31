data "azurerm_client_config" "current" {}

locals {
  tags = var.kv_additional_tags
}

resource "azurerm_key_vault" "this" {
  for_each                      = var.keyvaults
  name                          = each.value["keyvault_name"]
  location                      = each.value["location"]
  resource_group_name           = each.value["resource_group_name"]
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = each.value["kv_sku_name"]
  purge_protection_enabled      = each.value["purge_protection"]
  public_network_access_enabled = each.value["public_network_access_enabled"]
  tags                          = local.tags

  lifecycle {
    ignore_changes = [
      location,
      tenant_id
    ]
  }
}

# -
# - Key Vault Access Policy
# - Grant the current user Access to the Key Vault

data "azuread_group" "this" {
  count        = length(local.group_names)
  display_name = local.group_names[count.index]
}

data "azuread_user" "this" {
  count               = length(local.user_principal_names)
  user_principal_name = local.user_principal_names[count.index]
}

locals {
  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
    "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge"
  ]
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts",
    "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
  ]
  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey",
    "Restore", "Set", "SetSAS", "Update"
  ]

  access_policies_keys = {
    for access_policy_key, access_policy in var.access_policies :
    access_policy_key => keys(lookup(var.access_policies, access_policy_key))
  }
  access_policies = flatten([
    for access_policy_key, access_policy in var.access_policies : [
      {
        group_names             = contains(local.access_policies_keys[access_policy_key], "group_names") == true ? access_policy.group_names : []
        object_ids              = contains(local.access_policies_keys[access_policy_key], "object_ids") == true ? access_policy.object_ids : []
        user_principal_names    = contains(local.access_policies_keys[access_policy_key], "user_principal_names") == true ? access_policy.user_principal_names : []
        certificate_permissions = contains(local.access_policies_keys[access_policy_key], "certificate_permissions") == true ? access_policy.certificate_permissions : []
        key_permissions         = contains(local.access_policies_keys[access_policy_key], "key_permissions") == true ? access_policy.key_permissions : []
        secret_permissions      = contains(local.access_policies_keys[access_policy_key], "secret_permissions") == true ? access_policy.secret_permissions : []
        storage_permissions     = contains(local.access_policies_keys[access_policy_key], "storage_permissions") == true ? access_policy.storage_permissions : []
      }
    ]
  ])

  key_vault_ids_map = { for kv in azurerm_key_vault.this : kv.name => kv.id }

  group_names          = distinct(flatten(local.access_policies[*].group_names))
  user_principal_names = distinct(flatten(local.access_policies[*].user_principal_names))

  group_object_ids = { for g in data.azuread_group.this : lower(g.display_name) => g.id }
  user_object_ids  = { for u in data.azuread_user.this : lower(u.user_principal_name) => u.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each     = var.access_policies
  depends_on   = [azurerm_key_vault.this]
  key_vault_id = lookup(local.key_vault_ids_map, each.value["keyvault_name"])
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = lookup(each.value, "object_id", null)

  key_permissions         = lookup(each.value, "key_permissions", null)
  secret_permissions      = lookup(each.value, "secret_permissions", null)
  certificate_permissions = lookup(each.value, "certificate_permissions", null)
  storage_permissions     = lookup(each.value, "storage_permissions", null)
  lifecycle {
    ignore_changes = [
      tenant_id
    ]
  }
}

# -
# - Add Key Vault Secrets
# -
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = lookup(local.key_vault_ids_map, each.value["keyvault_name"])
  depends_on   = [azurerm_key_vault_access_policy.this]
}