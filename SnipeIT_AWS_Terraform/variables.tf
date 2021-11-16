//Define all required Variable here

variable "ec2_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "private_subnet_az1" {
  type = string
}

variable "vpc_id" {
  type = string
}
