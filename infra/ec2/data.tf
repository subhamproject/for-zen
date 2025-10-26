data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_key_pair" "keypair" {
  key_name = "demo"
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
