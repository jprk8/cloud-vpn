resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "client_config" {
  bucket = "${var.project_name}-client-config-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-bucket"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.client_config.id
  acl = "private"
}