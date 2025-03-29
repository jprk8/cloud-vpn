terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-west-1"
  profile = "vpn-prod"
}

# key pair generation for ec2 ssh
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
    Project = var.project_name
  }
}

resource "local_file" "private_key_pem" {
  content              = tls_private_key.ec2_key.private_key_pem
  filename             = "${path.module}/${var.project_name}-key.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

# Pass variables to modules
module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "ec2" {
  source               = "./modules/ec2"
  project_name         = var.project_name
  ami_id               = var.ami_id
  subnet_id            = module.vpc.subnet_id
  vpc_id               = module.vpc.vpc_id
  key_name             = aws_key_pair.ec2_key.key_name
  iam_instance_profile = module.iam.instance_profile_name
  s3_bucket_name       = module.s3.bucket_name
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}

module "iam" {
  source         = "./modules/iam"
  project_name   = var.project_name
  s3_bucket_name = module.s3.bucket_name
}
