module "ECS" {
  source        = "../../module/ecs"
  envname       = local.envname
  pvt_subnet_id = local.pvt_subnet_id
  pub_subnet_id = local.pub_subnet_id
  vpc_id        = local.vpc_id
}
