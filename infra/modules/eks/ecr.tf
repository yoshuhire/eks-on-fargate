resource "aws_ecr_repository" "this" {
  for_each = { for value in var.ecr_repo_list : value => value }

  name                 = "${var.env}/${each.value}"
  image_tag_mutability = "MUTABLE"

  force_delete = true

  tags = {
    Name = "${var.env}/${each.value}"
  }
}

resource "aws_ecr_repository_policy" "this" {
  for_each = { for value in var.ecr_repo_list : value => value }
  
  repository = aws_ecr_repository.this[each.value].name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DefaultDeny",
        "Effect": "Deny",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchImportUpstreamImage"
        ],
        "Condition": {
          "StringNotEquals": {
            "aws:PrincipalArn": concat([for fargate_role in aws_iam_role.fargate : fargate_role.arn],[data.aws_caller_identity.current.arn])
          }
        }
      }
    ]
  })
}

resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each = {
    for upstream in [ 
      {
        prefix                = "ecr-public",
        upstream_registry_url = "public.ecr.aws"
      },
      {
        prefix                = "k8s",
        upstream_registry_url = "registry.k8s.io"
      }
    ] : upstream.prefix => upstream
  }

  ecr_repository_prefix = "${var.env}/${each.key}"
  upstream_registry_url = each.value.upstream_registry_url
}
