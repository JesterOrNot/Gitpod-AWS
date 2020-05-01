provider "kubernetes" {
  load_config_file = false


  host                   = data.aws_eks_cluster.gitpod-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.gitpod-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.gitpod-cluster.token
}

provider "aws" {
  profile = var.aws.profile
  region  = var.aws.region
}

provider "http" {}
