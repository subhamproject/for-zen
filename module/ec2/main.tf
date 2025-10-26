# ALB Security Group — allows HTTP from internet
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP inbound from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
    Name = "${local.name} EC2 ALB Security Group"
  }
}

# EC2 Security Group — allows port 8080 only from ALB SG
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat-sg"
  description = "Allow HTTP from ALB only"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
 ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
    Name = "${local.name} Demo EC2 Security Group"
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "tomcat-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = flatten(local.pub_subnet_id)
}

# Target Group
resource "aws_lb_target_group" "tomcat_tg" {
  name        = "tomcat-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = local.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tomcat_tg.arn
  }
}

# Resource Block
resource "aws_instance" "ec2demo" {
  ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = local.key_pair
  count                  = 1
  subnet_id              = flatten(local.pub_subnet_id)[count.index]  #local.pvt_subnet_id
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-1.8.0-openjdk-devel wget
              cd /opt
              wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.111/bin/apache-tomcat-9.0.111.tar.gz
              tar xvf apache-tomcat-9.0.111.tar.gz
              mv apache-tomcat-9.0.111 tomcat9
              bash /opt/tomcat9/bin/startup.sh
              EOF
  tags = {
    "Name" = "${local.name} First Server-${count.index + 1}"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "tomcat_attachment" {
  count              = length(aws_instance.ec2demo)
  target_group_arn = aws_lb_target_group.tomcat_tg.arn
  target_id        = aws_instance.ec2demo[count.index].id
  port             = 8080
}
