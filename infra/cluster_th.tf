data "aws_caller_identity" "Me" {}
data "aws_region" "current" {}

resource "aws_eks_cluster" "EKSCluster" {
  name     = var.ClusterName
  role_arn = aws_iam_role.EKSAppRole.arn
  vpc_config {
    subnet_ids = [var.Subnet1, var.Subnet2]
  }
  depends_on = [
    aws_iam_role.EKSAppRole,
  ]
  tags = local.common_tags
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.EKSCluster.name
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.EKSCluster.name
  node_group_name = "${var.ClusterName}-workernodes"
  node_role_arn  = aws_iam_role.WorkerNodeRole.arn
  subnet_ids   = [var.Subnet1, var.Subnet1]
  instance_types = ["t3.small"]

  scaling_config {
  desired_size = 1
  max_size   = 1
  min_size   = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    ]
  tags = local.common_tags
}


resource "aws_ecr_repository" "thunderbolt" {
  name = "thunderbolt"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "kubernetes_service_account" "EKSServiceAccount" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    labels = {
      "app.kubernetes.io/component": "controller"
      "app.kubernetes.io/name": local.k8s_service_account_name
    }
    annotations = {
      # This annotation is needed to tell the service account which IAM role it
      # should assume
      "eks.amazonaws.com/role-arn" = aws_iam_role.LoadBalancerEKSServiceRole.arn
    }
  }
}

output "endpoint" {
  value = aws_eks_cluster.EKSCluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.EKSCluster.certificate_authority[0].data
}

output "eks-oidc-issuer" {
  value = local.eks_oidc_issuer
}

# terraform init
# terraform apply -input=false -auto-approve
# terraform destroy -auto-approve