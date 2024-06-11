data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "default" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}


### If default configuration has issue, manually get host with eks endpoints and run `AWS_PROFILE=sandbox-oliver aws eks get-token --cluster-name hw-eks` to get the token and manually fill in both for helm and kubernetes providers
provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token

}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}