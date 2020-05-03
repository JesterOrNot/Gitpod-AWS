module "vpc" {
  source = "./modules/vpc"
  kubernetes = var.kubernetes
  aws = var.aws
  subnet_count = 2
}

module "kubernetes" {
  source = "./modules/kubernetes"
  iam = var.iam
  gitpod = var.gitpod
  subnet_ids = module.vpc.aws_subnet.*.id
  vpc_id = module.vpc.aws_vpc.id
  kubernetes = var.kubernetes
}
