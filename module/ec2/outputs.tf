output "private_ip" {
  value = zipmap(aws_instance.ec2demo.*.tags.Name, aws_instance.ec2demo.*.private_ip)
}

output "private_dns" {
  value = zipmap(aws_instance.ec2demo.*.tags.Name, aws_instance.ec2demo.*.private_dns)
}
