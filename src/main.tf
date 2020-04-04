provider "aws" {
  profile = var.aws.profile
  region  = var.aws.region
}
resource "aws_instance" "Gitpod-AWS" {
  ami           = var.aws.ami
  instance_type = var.aws.instance_type
  key_name      = var.aws.key_name
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

provider "http" {}
