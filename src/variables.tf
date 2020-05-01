variable "aws" {
  type = object({
    region  = string
    profile = string
  })
}

variable "kubernetes" {
  type = object({
    cluster-name = string,
    vpc-name     = string
  })
}

variable "iam" {
  type = object({
    cluster-role-name = string
    node-role-name    = string
  })
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
