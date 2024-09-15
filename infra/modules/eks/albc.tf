#############
# IAM ポリシー AWS Load Balancer Controller 用
#############
resource "aws_iam_policy" "albc" {
  name   = "iampolicy-albc-${var.env}"
  policy = templatefile("${path.module}/policy/iampolicy-eks-cluster-albc.json", { ACCOUNT_ID = data.aws_caller_identity.current.account_id })

  tags = {
    Name = "iampolicy-albc-${var.env}"
  }
}

#############
# IAM ロール AWS Load Balancer Controller 用
#############
resource "aws_iam_role" "albc" {
  name = "iamrole-albc-${var.env}"
  assume_role_policy = templatefile("${path.module}/policy/iamrole-albc.json",
    {
      ACCOUNT_ID       = data.aws_caller_identity.current.account_id
      REGION           = var.region
      OIDC_PROVIDER_ID = regex("(.*)/(\\w+)$", replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", ""))[1]
      NAMESPACE        = "kube-system"
      SA_NAME          = "aws-load-balancer-controller"
    }
  )

  tags = {
    Name = "iamrole-albc-${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "albc" {
  role       = aws_iam_role.albc.name
  policy_arn = aws_iam_policy.albc.arn
}

#############
# Helmリリース AWS Load Balancer Controller 用
#############
resource "helm_release" "albc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"
  namespace  = "kube-system"
  timeout    = 300

  values = [
    templatefile("${path.module}/helm_value/albc.yml", {
      ACCOUNT_ID   = data.aws_caller_identity.current.account_id
      REGION       = var.region
      ENV          = var.env
      VPC_ID       = aws_vpc.this.id
      IAM_ROLE_ARN = aws_iam_role.albc.arn
      CLUSTER_ID   = aws_eks_cluster.this.id
      SA_NAME      = "aws-load-balancer-controller"
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.albc,
    aws_eks_addon.this
  ]
}
