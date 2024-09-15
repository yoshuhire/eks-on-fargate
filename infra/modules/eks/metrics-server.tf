#############
# Helmリリース metrics-server 用
#############
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.12.1"
  namespace  = "kube-system"
  timeout    = 300

  values = [
    templatefile("${path.module}/helm_value/metrics-server.yml", {
      ACCOUNT_ID = data.aws_caller_identity.current.account_id
      REGION     = var.region
      ENV        = var.env
    })
  ]

  depends_on = [
    aws_eks_addon.this
  ]
}
