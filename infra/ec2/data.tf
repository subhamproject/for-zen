data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


data "aws_key_pair" "keypair" {
  key_name = var.envname
}

data "aws_region" "current" {}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "dfa-${lower(var.envname)}-bucket"
    key    = "${lower(var.envname)}/vpc/vpc.tf"
    region = data.aws_region.current.name
  }
}



data "aws_ec2_instance_type_offering" "instance" {
  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3a.micro", "t3a.small", "t3a.medium"]
  }
  preferred_instance_types = ["t2.micro", "t3a.micro", "t3a.small", "t3a.medium"]
}
