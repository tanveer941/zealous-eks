variable "ProjectName" {
  type = string
  default = null
}
variable "ClusterName" {}
variable "GroupName" {}
variable "OwnerName" {}
variable "Moniker" {}
variable "AWSProfile" {
  type = string
  default = "default"
}
variable "Vpc" {}
variable "Subnet1" {}
variable "Subnet2" {}
variable "ServiceAccountName" {
  type = string
  default = "aws-load-balancer-controller"
}
variable "ServiceAccountNamespace" {
  type = string
  default = "default"
}

locals {
  common_tags = {
    group_name: var.GroupName
    owner_name: var.OwnerName
    "adsk:moniker": var.Moniker
  }
  k8s_service_account_name      = var.ServiceAccountName
  k8s_service_account_namespace = var.ServiceAccountNamespace

  # Get the EKS OIDC Issuer without https:// prefix
  eks_oidc_issuer = trimprefix(aws_eks_cluster.EKSCluster.identity.0.oidc.0.issuer, "https://")
}
