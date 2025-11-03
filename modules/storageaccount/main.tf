## create storage account

resource "azurerm_storage_account" "storage_acct" {
  for_each                        = var.storage_accounts
  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  is_hns_enabled                  = each.value.is_hns_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  allow_nested_items_to_be_public = each.value.allow_nested_items_to_be_public
  tags                            = var.sa_additional_tags
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "management" {
  for_each              = var.containers
  depends_on            = [azurerm_storage_account.storage_acct]
  name                  = each.value.name
  storage_account_name  = each.value.storage_account_name
  container_access_type = each.value.container_access_type
}