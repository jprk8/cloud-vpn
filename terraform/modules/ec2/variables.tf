variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name (generated in root)"
}

variable "iam_instance_profile" {
  type = string
  description = "IAM instance profile to attach to EC2"
}

variable "s3_bucket_name" {
  type = string
  description = "Name of S3 bucket to upload client config"
}