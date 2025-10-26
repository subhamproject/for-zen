# Create ECS Cluster
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "6.7.0"

  name = "${local.name}-ECScluster"
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 80
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 20
    }
  }

  tags = {
    Name = "${local.name}-ECSCluster"
  }
}
