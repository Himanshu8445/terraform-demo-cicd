module "resourcegroup" {
  source          = "../modules/resourcegroup"
  resource_groups = var.resource_groups
}

module "storage_acct" {
  source           = "../modules/storageaccount"
  storage_accounts = var.storage_accounts
  #containers         = var.containers
  sa_additional_tags = var.sa_additional_tags
  depends_on         = [module.resourcegroup]
}