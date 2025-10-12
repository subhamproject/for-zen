locals {
  account_id                 = data.aws_caller_identity.current.account_id
  region                     = data.aws_region.current.id
  name                       = var.envname
  vpc_cidr_block             = var.envname == "Prod" ? "10.50.0.0/16" : "192.168.0.0/16"
  availability_zones         = ["${data.aws_region.current.id}a", "${data.aws_region.current.id}b", "${data.aws_region.current.id}c"]
  public_subnets_cidr_block  = [cidrsubnet(local.vpc_cidr_block, 8, 1), cidrsubnet(local.vpc_cidr_block, 8, 2), cidrsubnet(local.vpc_cidr_block, 8, 3)]
  private_subnets_cidr_block = [cidrsubnet(local.vpc_cidr_block, 8, 4), cidrsubnet(local.vpc_cidr_block, 8, 5), cidrsubnet(local.vpc_cidr_block, 8, 6)]
  tags = {
    "Environment" : "${var.envname} GH Runner"
  }
}
