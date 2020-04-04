provider "aws" {
  profile = var.aws.profile
  region  = var.aws.region
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

provider "http" {}
