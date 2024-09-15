output "endpoint" {
  description = "EKS API Endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "certificate_authority" {
  description = "EKS CA"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
  description = "EKS Cluster 名"
  value       = aws_eks_cluster.this.id
}

output "alb_sg_id" {
  description = "webサーバーフロントALBにアタッチするセキュリティグループのID"
  value       = aws_security_group.alb.id
}