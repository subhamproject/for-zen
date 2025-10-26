output "private_ip" {
  value = module.EC2.private_ip
}

output "private_dns" {
  value = module.EC2.private_dns
}
