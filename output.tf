output "ssm_start_session_command_ubuntu_pro_server" {
  value = var.create_ubuntu_pro_server ? "aws ssm start-session --target ${module.ubuntu_pro_server[0].instance_id}" : null
}
