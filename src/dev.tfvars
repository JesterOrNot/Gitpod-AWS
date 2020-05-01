aws = {
  region  = "us-east-2"
  profile = "default"
}
iam = {
  cluster-role-name = "cluster-policy"
  node-role-name    = "node-policy"
}
kubernetes = {
  cluster-name = "gitpod-cluster-2"
  vpc-name     = "terraform-eks-gitpod-node"
}
gitpod = {
  provider      = "GitHub"
  id            = "Gitpod-AWS"
  protocol      = "http"
  domain        = "sean.gitpod-self-hosted.com"
  host-url      = "github.com"
  client-id     = "a0d9f23f71a890a581e8"
  client-secret = "8f8168940ea7737a69da9dd732b0c879f612ec50"
  settings-url  = "https://github.com/settings/connections/applications/a0d9f23f71a890a581e8"
}
