locals {
  region        = data.aws_region.current.name
  envname       = var.envname
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = data.aws_ec2_instance_type_offering.instance.id
  pub_subnet_id = data.terraform_remote_state.network.outputs.public_subnets_id
  pvt_subnet_id = data.terraform_remote_state.network.outputs.private_subnets_id
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
  key_pair      = data.aws_key_pair.keypair.key_name
}
