provider "aws" {
  region = "ap-southeast-1" // Define AWS Region based on your current setup.
}

//Below is completely optional, if you like to store terraform state files on S3 bucket please use below codes.
terraform {
  backend "s3" {
    bucket = "infra-terraform-states-backup"
    key    = "terraform/snipeit/terraform.tfstate"
    region = "ap-southeast-1" //define your region name
  }
}

module "snipeit" {
  source             = "/"
  ec2_name           = "snipeit"
  ami_id             = "ami-0adfdaea54d40922b" // Get AMI-ID based on your region
  instance_type      = "t2.medium"
  key_name           = "snipeit"              //I am using existing SSH key
  private_subnet_az1 = "subnet-sajk121293488" // Using existing Private Subnet
  vpc_id             = "vpc-123i32831hdssajd" //Using existing VPC ID

}
