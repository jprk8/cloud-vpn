resource "aws_security_group" "vpn_sg" {
  name        = "${var.project_name}-vpn-sg"
  description = "Allow WireGuard and SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "WireGuard access"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-vpn-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]
  key_name               = var.key_name
  user_data              = templatefile("${path.module}/user-data.sh", {
    S3_BUCKET = var.s3_bucket_name
  })
  iam_instance_profile   = var.iam_instance_profile

  tags = {
    Name    = "${var.project_name}-vpn-ec2"
    Project = var.project_name
  }
}
