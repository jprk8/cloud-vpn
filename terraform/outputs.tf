output "vpn_private_key_file" {
  value = local_file.private_key_pem.filename
}

output "vpn_public_ip" {
  value = module.ec2.public_ip
}

output "vpn_ssh_command" {
  value = "ssh -i ${local_file.private_key_pem.filename} ubuntu@${module.ec2.public_ip}"
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "download_client_config_command" {
  description = "Command to download client config from S3"
  value = "aws s3 cp s3://${module.s3.bucket_name}/wg-client.conf ./wg-client.conf"
}