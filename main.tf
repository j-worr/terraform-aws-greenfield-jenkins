terraform {
  backend "s3" {
    bucket         =  "jw-tfbucket"
    key            = "terraform-aws-greenfield-ec2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
  }
}

locals {
  common_tags = {
    Env = "greenfield-ec2 deployment via terraform"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Env = "test - deployed with terraform"
    }
  }
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet"
  }
}


resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.myvpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygateway.id
}


resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-sg"
  }
  
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
  instance_type          = var.instancetype
  subnet_id              = aws_subnet.mysubnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = var.keyname
  tags = {
    Name = "my-instance"
  }
}