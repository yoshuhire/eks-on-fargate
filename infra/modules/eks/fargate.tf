resource "time_sleep" "cluster" {

  create_duration = "30s"

  triggers = {
    cluster_name     = aws_eks_cluster.this.name
    cluster_endpoint = aws_eks_cluster.this.endpoint
    cluster_version  = aws_eks_cluster.this.version

    cluster_certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
  }
}

#############
# Fargate IAM
#############
data "aws_iam_policy_document" "fargate" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate" {
  for_each = { for k, v in var.fargate_profile_config : k => v }

  name = "iamrole-eks-cluster-fargate-${each.key}-${var.env}"

  assume_role_policy    = data.aws_iam_policy_document.fargate.json
  force_detach_policies = true

  tags = {
    Name = "iamrole-eks-cluster-fargate-${each.key}-${var.env}"
  }
}

resource "aws_iam_policy" "fargate" {
  for_each = { for policy in [
    {
      name   = "iampolicy-eks-cluster-fargate-pod-exec"
      policy = templatefile("${path.module}/policy/iampolicy-eks-cluster-fargate-pod-exec.json", { ACCOUNT_ID = data.aws_caller_identity.current.account_id })
    },
    {
      name   = "iampolicy-eks-cluster-fargate-vpc-cni"
      policy = templatefile("${path.module}/policy/iampolicy-eks-cluster-fargate-vpc-cni.json", { ACCOUNT_ID = data.aws_caller_identity.current.account_id })
    }
  ] : policy.name => policy }

  name   = "${each.key}-${var.env}"
  policy = each.value.policy

  tags = {
    Name = "${each.key}-${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "fargate_pod_exec" {
  for_each = { for k, v in var.fargate_profile_config : k => v }

  policy_arn = aws_iam_policy.fargate["iampolicy-eks-cluster-fargate-pod-exec"].arn
  role       = aws_iam_role.fargate[each.key].name
}

resource "aws_iam_role_policy_attachment" "fargate_vpc_cni" {
  for_each = { for k, v in var.fargate_profile_config : k => v }

  policy_arn = aws_iam_policy.fargate["iampolicy-eks-cluster-fargate-vpc-cni"].arn
  role       = aws_iam_role.fargate[each.key].name
}

#############
# Fargate Profile
#############
resource "aws_eks_fargate_profile" "this" {
  for_each = { for k, v in var.fargate_profile_config : k => v }

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "fp-${each.key}"
  pod_execution_role_arn = aws_iam_role.fargate[each.key].arn
  subnet_ids             = [for subnet in aws_subnet.private : subnet.id]

  dynamic "selector" {
    for_each = each.value.selectors

    content {
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }

  tags = {
    Name = "fp-${each.key}"
  }
}
