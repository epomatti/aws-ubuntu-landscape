output "ssm_start_session_command_ubuntu_pro_server" {
  value = var.create_ubuntu_pro_server ? "aws ssm start-session --target ${module.ubuntu_pro_server[0].instance_id}" : null
}

output "landscape_host_public_ip" {
  value = var.create_ubuntu_landscape ? module.ubuntu_landscape[0].public_ip : null
}

output "landscape_server_fqdn" {
  value = var.landscape_server_fqdn
}

output "landscape_certbot_email" {
  value = var.landscape_certbot_email
}
