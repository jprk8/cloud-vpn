output "vpn_private_key_file" {
  value = local_file.private_key_pem.filename
}

output "vpn_public_ip" {
  value = module.ec2.public_ip
}

output "vpn_ssh_command" {
  value = "ssh -i ${local_file.private_key_pem.filename} ubuntu@${module.ec2.public_ip}"
}
