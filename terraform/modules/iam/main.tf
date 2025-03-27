resource "aws_iam_role" "ec2_upload_role" {
  name = "${var.project_name}-ec2-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "${var.project_name}-ec2-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "s3_upload_policy" {
  name = "${var.project_name}-s3-upload-policy"
  role = aws_iam_role.ec2_upload_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3.PutObject"
      ]
      Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "vpn_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_upload_role.name
}
