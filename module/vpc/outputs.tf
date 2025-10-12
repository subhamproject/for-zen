output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.vpc.cidr_block, "")
}

output "public_subnets_id" {
  value = [aws_subnet.public_subnet.*.id]
}

output "private_subnets_id" {
  value = [aws_subnet.private_subnet.*.id]
}

output "public_route_table" {
  value = aws_route_table.public.id
}
