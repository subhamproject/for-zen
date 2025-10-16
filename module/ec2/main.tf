#Security Group
locals {
  ingress_ports = [8080, 80, 22]
  egress_ports  = [0]
}

resource "aws_security_group" "web_sg" {
  name   = "${local.name} Security Group"
  vpc_id = local.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${local.name} Instance SG"
  }
}

# Resource Block
resource "aws_instance" "ec2demo" {
  ami                    = local.ami 
  instance_type          = "t.micrs" #local.instance_type
  key_name               = local.key_pair
  count                  = 1
  subnet_id              = flatten(local.pvt_subnet_id)[count.index]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 3
    volume_type = "gp2"
  }
  ebs_block_device {
    device_name = "/dev/xvdg"
    volume_size = 2
    volume_type = "gp2"
  }

  provisioner "file" {
    source      = "./format.sh"
    destination = "/tmp/format.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y jenkins java-11-openjdk-devel",
      "sudo yum -y install wget",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo amazon-linux-extras install nginx1.12 -y",
      "sudo systemctl start nginx"
    ]
    on_failure = continue
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "sudo /tmp/format.sh"
    ]
    on_failure = continue
  }

 provisioner "remote-exec" {
  inline = ["sudo hostnamectl set-hostname jenkins.example.com"]
  on_failure = continue
}

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "ec2-user"
    private_key = file("../../infra/vpc/${local.key_pair}.pem")
  }

  tags = {
    "Name" = "${local.name} First Server-${count.index + 1}"
  }
}
