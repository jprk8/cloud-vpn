variable "project_name" {
  type = string
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket the EC2 will upload to"
}
