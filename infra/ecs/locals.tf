locals {
  region        = data.aws_region.current.id
  envname       = var.envname
  pvt_subnet_id = data.terraform_remote_state.network.outputs.private_subnets_id
  pub_subnet_id = data.terraform_remote_state.network.outputs.public_subnets_id
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
}
