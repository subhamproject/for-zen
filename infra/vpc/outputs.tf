output "vpc_id" {
  value = module.VPC.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.VPC.vpc_cidr_block
}


output "public_subnets_id" {
  value = [module.VPC.public_subnets_id]
}

output "private_subnets_id" {
  value = [module.VPC.private_subnets_id]
}


output "public_route_table" {
  value = module.VPC.public_route_table
}
