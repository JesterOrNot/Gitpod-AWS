variable "iam" {
  type = object({
    cluster-role-name = string
    node-role-name    = string
  })
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "gitpod" {
  type = object({
    provider      = string
    domain        = string
    id            = string
    protocol      = string
    host-url      = string
    client-id     = string
    client-secret = string
    settings-url  = string
  })
}

variable "kubernetes" {
  type = object({
    cluster-name = string,
    vpc-name     = string
  })
}
variable "aws" {
  type = object({
    region  = string
    profile = string
  })
}