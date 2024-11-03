resource "aws_ssm_parameter" "landscape_server" {
  name  = "landscape-server-instance-id"
  type  = "String"
  value = var.landscape_server_instance_id
}
