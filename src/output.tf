output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "cluster_name" {
  value = var.kubernetes.cluster-name
}

output "region" {
  value = var.aws.region
}
