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

provider "helm" {
  version = "2.2.0"
  kubernetes {
    host                   = aws_eks_cluster.EKSCluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.EKSCluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.EKSCluster.id]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.EKSCluster.id
  }

  set {
    name  = "image.tag"
    value = "v2.4.2"
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.LoadBalancerEKSServiceRole.arn
  }

  depends_on = [
    aws_eks_node_group.ZealousWorkerNodes,
    aws_iam_role.LoadBalancerEKSServiceRole
  ]
}