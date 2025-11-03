## RESOURCE GROUPS
resource_groups = {
  rg_1 = {
    name     = "rg-dlz-test-eus-001"
    location = "eastus"
    tags = {
      iac = "Terraform"
    }
  },
  rg_2 = {
    name     = "rg-dlz-test-eus-002"
    location = "eastus"
    tags = {
      iac = "Terraform"
    }
  }
}

## STORAGE ACCOUNTS
storage_accounts = {
  str_acct_1 = {
    name                            = "studfsxeus201bronze"
    sku                             = "Standard_LRS"
    resource_group_name             = "rg-dlz-test-eus-001"
    location                        = "eastus"
    is_hns_enabled                  = false
    network_rules                   = null
    public_network_access_enabled   = true
    allow_nested_items_to_be_public = true
  }
}

# containers = {}
sa_additional_tags = {
  iac = "Terraform"
}