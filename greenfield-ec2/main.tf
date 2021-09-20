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
}

resource "aws_instance" "myinstance" {
  ami = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet.id  
  tags = {
    Name = "example instance"
  }

}
