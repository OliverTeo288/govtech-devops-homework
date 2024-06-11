data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.1"

  cluster_name    = "hw-eks"
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.app_subnets

  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }


  eks_managed_node_group_defaults = {
    ami_type  = "AL2023_ARM_64_STANDARD"
    disk_size = 50
  }

  eks_managed_node_groups = {
    hw-worker-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t4g.medium"]
    }
  }


}


