variable "region" {
    default = "us-east-2"
}
variable "ami" {
    default = "ami-0fc20dd1da406780b"
}
provider "aws" {
  profile = "default"
  region  = var.region
}
resource "aws_instance" "Gitpod-AWS" {
  ami           = var.ami
  instance_type = "t2.micro"
  provisioner "remote-exec" {
    inline = [
      "./clone.sh",
      "./deps.sh",
      "helm repo add charts.gitpod.io https://charts.gitpod.io",
      "helm dep update",
      "helm upgrade --install $(for i in $(cat configuration.txt); do echo -e \"-f $i\"; done) gitpod ."
    ]
  }
}
