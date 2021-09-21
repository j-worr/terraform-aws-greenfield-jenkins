terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.16.0"
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
  vpc_id =  aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch =  true
}


resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route" "route" {
  route_table_id            =  aws_vpc.myvpc.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id		    = aws_internet_gateway.mygateway.id
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
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet.id  
  tags = {
    Name = "example instance"
  }

}
