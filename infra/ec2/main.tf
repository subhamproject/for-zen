module "EC2" {
  source        = "../../module/ec2"
  envname       = local.envname
  ami           = local.ami
  vpc_id        = local.vpc_id
  instance_type = local.instance_type
  pub_subnet_id = local.pub_subnet_id
  pvt_subnet_id = local.pvt_subnet_id
  key_pair      = local.key_pair
}
