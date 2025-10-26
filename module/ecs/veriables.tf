variable "envname" {
  type        = string
  description = "The Environment name"
}


variable "pvt_subnet_id" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "pub_subnet_id" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
}
