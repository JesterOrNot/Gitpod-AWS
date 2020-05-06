output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "cluster_name" {
  value = var.kubernetes.cluster-name
}

output "region" {
  value = var.aws.region
}

output "mysql_password" {
  value = var.database.password
}

output "mysql_username" {
  value = var.database.user-name
}

output "mysql_endpoint" {
  value = aws_db_instance.gitpod.endpoint
}

output "mysql_port" {
  value = aws_db_instance.port
}
