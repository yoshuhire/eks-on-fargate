module "eks" {
  source = "./modules/eks"

  env = var.env

  accessible_ip_list = {
    to_web_server      = ["0.0.0.0/0"] # webサーバーへのHTTPリクエスト許可IPリスト
    to_kube_api_server = ["0.0.0.0/0"] # kubectl 実行許可IPリスト
  }
}

output "alb_sg_id" {
  description = "service.yml 内に入力する Webサーバーへのアクセス制御用セキュリティグループのID"
  value       = module.eks.alb_sg_id
}
