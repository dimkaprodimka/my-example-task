
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

data "aws_region" "current" {}


resource "aws_instance" "app_server" {
  ami                    = var.instance_AMI
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]
  subnet_id              = aws_subnet.pub_subnet.id
  user_data              = <<-EOL
  #!/bin/bash -xe
  yum -y update
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd 
  EOL
  tags = {
    Name        = var.instance_tag
    Environment = var.environment
  }
}

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name        = "app VPC"
    Environment = var.environment
  }
}

resource "aws_subnet" "pub_subnet" {
  //count             = length(var.publicCIDR)
  vpc_id = aws_vpc.app_vpc.id
  //cidr_block        = element(var.publicCIDR, count.index)
  cidr_block              = var.publicCIDR
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = "true"
  tags = {
    Name        = "app"
    Environment = var.environment
    #Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name        = "app"
    Environment = var.environment
  }
}

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name        = "Internet gw app"
    Environment = var.environment
  }


}

resource "aws_route_table_association" "app_rt_as" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.app_rt.id

}

resource "aws_security_group" "app_sg" {
  name   = "app_ports"
  vpc_id = aws_vpc.app_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "my rules app"
    Environment = var.environment
  }
}