variable "project_name" {
  description = "Project name for tag prefix"
  type        = string
}

# vpc variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the subnet"
  type        = string
}

# ec2 variables
variable "ami_id" {
  type        = string
  description = "Ubuntu 24.04 AMI ID"
}
