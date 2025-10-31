module "resourcegroup" {
  source          = "../modules/resourcegroup"
  resource_groups = var.resource_groups
}