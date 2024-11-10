resource "aws_ssm_parameter" "landscape_fqdn" {
  name  = "landscape-server-fqdn"
  type  = "String"
  value = var.landscape_server_fqdn
}

resource "aws_ssm_parameter" "landscape_certbot_email" {
  name  = "landscape-server-certbot-email"
  type  = "String"
  value = var.landscape_certbot_email
}

resource "aws_ssm_parameter" "landscape_server" {
  name  = "landscape-server-instance-id"
  type  = "String"
  value = var.landscape_server_instance_id
}
