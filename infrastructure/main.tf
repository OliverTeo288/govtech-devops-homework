terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">5"
    }
  }
}


provider "aws" {
  region  = "ap-southeast-1"
  profile = var.profile
}

module "domain" {
  source               = "./modules/domain"
  hosted_zone_domain   = var.hosted_zone_domain
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  app_acm_domains = module.acm.app_cert

  hw_ingress_domain  = module.eks.hw_ingress_hostname
  hw_ingress_zone_id = module.eks.hw_ingress_zone_id
}

module "acm" {
  source     = "./modules/acm"
  app_domain = var.hosted_zone_domain

}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.hw_vpc.id
}

module "routetables" {
  source = "./modules/routetables"

  vpc_id              = module.vpc.hw_vpc.id
  main_route_table_id = module.vpc.hw_vpc.default_route_table_id

  public_subnet_a_id = module.subnet.public_subnet_a.id
  public_subnet_b_id = module.subnet.public_subnet_b.id

  app_subnet_a_id = module.subnet.app_subnet_a.id
  app_subnet_b_id = module.subnet.app_subnet_b.id
}

module "security_groups" {
  source = "./modules/securitygroups"
  vpc_id = module.vpc.hw_vpc.id


}

module "oidc" {
  source = "./modules/github_oidc"

  github_organization = "OliverTeo288"
  github_repositories = ["govtech-devops-homework"]
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
}

module "ecr" {
  source = "./modules/ecr"
}

# module "bastion" {

#   source = "./modules/bastion"

#   app_subnet_a_id = module.subnet.app_subnet_a.id
#   app_sg_id       = module.security_groups.app_security_group.id

# }

module "eks" {
  source = "./modules/eks"

  vpc_id      = module.vpc.hw_vpc.id
  app_subnets = [module.subnet.app_subnet_a.id, module.subnet.app_subnet_b.id]
  app_acm_arn = module.acm.app_cert.arn

  app_ecr = module.ecr.hw_ecr.repository_url
}