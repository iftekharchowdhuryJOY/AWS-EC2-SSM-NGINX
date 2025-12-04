#############################################
# Provider
#############################################
provider "aws" {
  region = "ca-central-1"
}

#############################################
# IAM Role for SSM (No SSH needed)
#############################################
resource "aws_iam_role" "ec2_ssm_role" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#############################################
# Security Group — NO SSH (Most Secure)
#############################################
resource "aws_security_group" "nginx_sg" {
  name        = "secure-nginx-sg"
  description = "Only allow HTTP for Nginx"
  vpc_id      = data.aws_vpc.default.id

  # NGINX ONLY
  ingress {
    description = "HTTP for Nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND allowed
  egress {
    description = "Outbound allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-nginx-sg"
  }
}

#############################################
# Default VPC & Subnets
#############################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#############################################
# AMI (Amazon Linux 2023)
#############################################
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

#############################################
# User Data — Install Nginx Automatically
#############################################
locals {
  nginx_user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install nginx -y
    systemctl start nginx
    systemctl enable nginx
  EOF
}

#############################################
# Instance Profile for IAM Role
#############################################
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

#############################################
# EC2 Instance (SSM-ONLY access)
#############################################
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data                   = local.nginx_user_data

  # NO SSH KEY (secure-by-default)
  key_name = null

  tags = {
    Name = "ssm-nginx-server"
  }
}
