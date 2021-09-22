terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.myvpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygateway.id
}


resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "myinstance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.mysubnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = "mykey"
  tags = {
    Name = "example instance"
  }
}
