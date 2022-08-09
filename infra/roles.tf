### IAM Role ###
data "aws_iam_policy_document" "EKSRoleAssumePolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "EKSLoadBalancerPolicy" {

}

## EKS Role ##
resource "aws_iam_role" "EKSAppRole" {
  name = "${var.ProjectName}-EKSRole"
  assume_role_policy = data.aws_iam_policy_document.EKSRoleAssumePolicy.json
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "PodsAccess" {
  role = aws_iam_role.EKSAppRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "ClusterPolicy" {
  role = aws_iam_role.EKSAppRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnlyEKS" {
  role    = aws_iam_role.EKSAppRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Worker Node role
resource "aws_iam_role" "WorkerNodeRole" {
  name = "${var.ProjectName}-WorkerNodeEKSRole"
  assume_role_policy = jsonencode({
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
  }]
  Version = "2012-10-17"
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy" "EKSWorkerLoadBalancerPolicy" {
  name = "${var.ProjectName}-LoadBalancerPolicy"
  role = aws_iam_role.WorkerNodeRole.id
  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.WorkerNodeRole.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodeClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role    = aws_iam_role.WorkerNodeRole.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.WorkerNodeRole.id
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.WorkerNodeRole.id
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.WorkerNodeRole.id
}

# Load Balancer Role
data "aws_iam_policy_document" "LoadBalancerEKSServicePolicy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.Me.account_id}:oidc-provider/${local.eks_oidc_issuer}"
      ]
    }

    # Limit the scope so that only our desired service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values = [
        "system:serviceaccount:kube-system:${local.k8s_service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role_policy" "LoadBalancerServicePolicy" {
  name = "${var.ProjectName}-LoadBalancerServicePolicy"
  role = aws_iam_role.LoadBalancerEKSServiceRole.id
  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role" "LoadBalancerEKSServiceRole" {
  name = "${var.ProjectName}-LoadBalancerServiceRole"
  assume_role_policy = data.aws_iam_policy_document.LoadBalancerEKSServicePolicy.json
  tags = local.common_tags
}