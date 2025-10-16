variable "envname" {
  type        = string
  description = "The Environment name"
}

variable "ami" {
  type        = string
  description = "AWS AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance Type"
}

variable "pub_subnet_id" {
  type        = list
  description = "CIDR block for Public Subnet"
}

variable "pvt_subnet_id" {
  type        = list
  description = "CIDR block for Private Subnet"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "key_pair" {
  type        = string
  description = "AWS Key Pair"
}

