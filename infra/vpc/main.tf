module "VPC" {
  source                     = "../../module/vpc"
  name                       = local.name
  region                     = local.region
  availability_zones         = local.availability_zones
  vpc_cidr_block             = local.vpc_cidr_block
  public_subnets_cidr_block  = local.public_subnets_cidr_block
  private_subnets_cidr_block = local.private_subnets_cidr_block
  vpc_tags                   = local.tags
}
