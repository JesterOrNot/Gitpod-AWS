variable "aws" {
  type = object({
    region        = string
    ami           = string
    profile       = string
    key_name      = string
    instance_type = string
  })
  default = {
    region        = "us-east-2"
    ami           = "ami-0fc20dd1da406780b"
    profile       = "default"
    key_name      = "power"
    instance_type = "t2.micro"
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
