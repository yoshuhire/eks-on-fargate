#############
# EKS IAM
#############
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name = "iamrole-eks-cluster-${var.env}"

  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true

  inline_policy {
    name = "deny-create-cloudwatchLogGroup"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogGroup"]
          Effect   = "Deny"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Name = "iamrole-eks-cluster-${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = { for k, v in {
    AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  } : k => v }

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

#############
# EKS Cloudwacth Group
#############
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/eks-cluster-${var.env}/cluster"
  retention_in_days = 7

  tags = {
    Name = "/aws/eks/eks-cluster-${var.env}/cluster"
  }
}

#############
# EKS Cluster
#############
resource "aws_eks_cluster" "this" {
  name                      = "eks-cluster-${var.env}"
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_config.version
  enabled_cluster_log_types = var.cluster_config.enabled_log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids = concat(
      [for subnet in aws_subnet.private : subnet.id],
      [for subnet in aws_subnet.public : subnet.id],
    )
    endpoint_private_access = var.cluster_config.endpoint_private_access
    endpoint_public_access  = var.cluster_config.endpoint_public_access
    public_access_cidrs     = var.accessible_ip_list.to_kube_api_server
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = "eks-cluster-${var.env}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_cloudwatch_log_group.cluster,
  ]
}

#############
# EKS OIDC
#############
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = {
    Name = "irsa-eks-cluster-${var.env}"
  }
}

#############
# EKS Addon
#############
data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_config.addons : k => v }

  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = try(each.value.most_recent, null)
}

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_config.addons : k => v }

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key

  addon_version               = data.aws_eks_addon_version.this[each.key].version
  configuration_values        = try(jsonencode(each.value.configuration_values), null)
  preserve                    = true

  depends_on = [
    aws_eks_fargate_profile.this,
    aws_vpc_endpoint.this,
  ]

  tags = {
    Name = "${aws_eks_cluster.this.name}-${each.key}"
  }
}

#############
# aws-auth configmap
#############
data "aws_caller_identity" "current" {}

locals {
  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      # faragte
      [
        for role in aws_iam_role.fargate : {
          rolearn  = role.arn
          username = "system:node:{{SessionName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes",
            "system:node-proxier",
          ]
        }
      ],
      var.cluster_config.aws_auth_roles
    ))
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.aws_auth,
  ]
}