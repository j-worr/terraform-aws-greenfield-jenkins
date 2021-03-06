variable "region" {
  type = string
  default = "us-east-1"
}

variable "instancetype" {
  type = string
  default = "t2.micro"
}

variable "keyname" {
  type = string
  description = "ec2 key"
  default = "roobee"
}