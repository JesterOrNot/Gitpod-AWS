variable "aws" {
    type = object({
        region = string
        ami = string
        profile = string
        key_name = string
        instance_type = string
    })
    default = {
        region = "us-east-2"
        ami = "ami-0fc20dd1da406780b"
        profile = "default"
        key_name = "gitpod"
        instance_type = "t2.micro"
    }
}
provider "aws" {
  profile = var.aws.profile
  region  = var.aws.region
}
resource "aws_instance" "Gitpod-AWS" {
  ami           = var.aws.ami
  instance_type = var.aws.instance_type
  key_name = var.aws.key_name
}
