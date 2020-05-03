variable "kubernetes" {
  type = object({
    cluster-name = string,
    vpc-name     = string
  })
}

variable "subnet_count" {
    type        = string
}

variable "aws" {
  type = object({
    region  = string
    profile = string
  })
}