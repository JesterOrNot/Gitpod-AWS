variable "aws" {
  type = object({
    region        = string
    profile       = string
  })
  default = {
    region        = "us-east-2"
    profile       = "default"
  }
}
variable "kubernetes" {
  type = object({
    cluster-name = string,
    vpc-name     = string
  })
  default = {
    cluster-name = "gitpod-cluster"
    vpc-name     = "terraform-eks-gitpod-node"
  }
}
