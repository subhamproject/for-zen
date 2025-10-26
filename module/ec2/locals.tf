locals {
  name          = var.envname
  ami           = var.ami
  instance_type = var.instance_type
  pvt_subnet_id = var.pvt_subnet_id
  key_pair      = var.key_pair
  vpc_id        = var.vpc_id
  pub_subnet_id = var.pub_subnet_id
}
