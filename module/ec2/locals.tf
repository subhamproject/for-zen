locals {
  name                       = var.envname
  ami                        = var.ami
  instance_type              = var.instance_type
  pub_subnet_id              = var.pub_subnet_id
  pvt_subnet_id              = var.pvt_subnet_id
  vpc_id                     = var.vpc_id
  key_pair                   = var.key_pair
}
