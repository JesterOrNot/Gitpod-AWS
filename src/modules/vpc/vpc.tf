# To use EKS one needs a VPC or Virtual Private Cloud for base networking and this adds it.
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name"                                                 = var.kubernetes.vpc-name
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}" = "shared"
  }
}
