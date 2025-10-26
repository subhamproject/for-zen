data "aws_ssm_parameter" "ami" {
  #name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

data "aws_region" "current" {}
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "${var.envname}/vpc/vpc.tf"
    region = data.aws_region.current.id
  }
}
