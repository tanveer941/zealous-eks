terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 3.0"
  region = "us-east-1"
  profile = var.AWSProfile
}

provider "kubernetes" {
  host                   = aws_eks_cluster.EKSCluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.EKSCluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  config_path            = "~/.kube/config"
}