<!-- BEGIN_TF_DOCS -->
## Diagram

![diagram](./images/eks_on_fargate.drawio.png)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.40 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.12.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.40 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.12.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.27.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_pull_through_cache_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_fargate_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.albc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.albc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.albc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fargate_pod_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fargate_vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.public_to_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [helm_release.albc](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [time_sleep.cluster](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accessible_ip_list"></a> [accessible\_ip\_list](#input\_accessible\_ip\_list) | アクセス許可IPリスト | <pre>object({<br>    to_web_server      = list(string)<br>    to_kube_api_server = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | EKS クラスター設定 | <pre>object({<br>    version                 = string<br>    enabled_log_types       = list(string)<br>    endpoint_private_access = bool<br>    endpoint_public_access  = bool<br>    addons              = any<br>    aws_auth_roles = list(object({<br>      rolearn  = string<br>      username = string<br>      groups   = list(string)<br>    }))<br>  })</pre> | <pre>{<br>  "addons": {<br>    "coredns": {<br>      "configuration_values": {<br>        "computeType": "Fargate"<br>      },<br>      "most_recent": true<br>    },<br>    "vpc-cni": {<br>      "most_recent": true<br>    }<br>  },<br>  "aws_auth_roles": [],<br>  "enabled_log_types": [<br>    "audit",<br>    "api",<br>    "authenticator"<br>  ],<br>  "endpoint_private_access": true,<br>  "endpoint_public_access": true,<br>  "version": "1.29"<br>}</pre> | no |
| <a name="input_ecr_repo_list"></a> [ecr\_repo\_list](#input\_ecr\_repo\_list) | ECR リポジトリリスト | `list(string)` | <pre>[<br>  "ecr-public/eks/aws-load-balancer-controller",<br>  "web-server",<br>  "k8s/metrics-server/metrics-server",<br>  "k8s/autoscaling/addon-resizer"<br>]</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | 本開区分の指定(prd or dev) | `string` | n/a | yes |
| <a name="input_fargate_profile_config"></a> [fargate\_profile\_config](#input\_fargate\_profile\_config) | Fargateプロファイル設定 | `any` | <pre>{<br>  "default": {<br>    "name": "default",<br>    "selectors": [<br>      {<br>        "namespace": "default"<br>      },<br>      {<br>        "namespace": "kube-system"<br>      }<br>    ]<br>  },<br>  "web-server": {<br>    "selectors": [<br>      {<br>        "namespace": "web-server"<br>      }<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | リージョン | `string` | `"ap-northeast-1"` | no |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | サブネット設定 | <pre>map(list(object({<br>    availability_zone = string<br>    cidr_block        = string<br>  })))</pre> | <pre>{<br>  "private": [<br>    {<br>      "availability_zone": "ap-northeast-1a",<br>      "cidr_block": "192.168.0.0/24"<br>    },<br>    {<br>      "availability_zone": "ap-northeast-1c",<br>      "cidr_block": "192.168.1.0/24"<br>    },<br>    {<br>      "availability_zone": "ap-northeast-1d",<br>      "cidr_block": "192.168.2.0/24"<br>    }<br>  ],<br>  "public": [<br>    {<br>      "availability_zone": "ap-northeast-1a",<br>      "cidr_block": "192.168.3.0/24"<br>    },<br>    {<br>      "availability_zone": "ap-northeast-1c",<br>      "cidr_block": "192.168.4.0/24"<br>    },<br>    {<br>      "availability_zone": "ap-northeast-1d",<br>      "cidr_block": "192.168.5.0/24"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC設定 | <pre>object({<br>    cidr_block           = string<br>    enable_dns_support   = bool<br>    enable_dns_hostnames = bool<br>  })</pre> | <pre>{<br>  "cidr_block": "192.168.0.0/16",<br>  "enable_dns_hostnames": true,<br>  "enable_dns_support": true<br>}</pre> | no |
| <a name="input_vpce_config"></a> [vpce\_config](#input\_vpce\_config) | VPCE設定リスト | <pre>list(object({<br>    usage             = string<br>    service_name      = string<br>    vpc_endpoint_type = string<br>  }))</pre> | <pre>[<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.s3",<br>    "usage": "s3",<br>    "vpc_endpoint_type": "Gateway"<br>  },<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.ecr.api",<br>    "usage": "ecr.api",<br>    "vpc_endpoint_type": "Interface"<br>  },<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.ecr.dkr",<br>    "usage": "ecr.dkr",<br>    "vpc_endpoint_type": "Interface"<br>  },<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.sts",<br>    "usage": "sts",<br>    "vpc_endpoint_type": "Interface"<br>  },<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.ec2",<br>    "usage": "ec2",<br>    "vpc_endpoint_type": "Interface"<br>  },<br>  {<br>    "service_name": "com.amazonaws.ap-northeast-1.elasticloadbalancing",<br>    "usage": "elasticloadbalancing",<br>    "vpc_endpoint_type": "Interface"<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_sg_id"></a> [alb\_sg\_id](#output\_alb\_sg\_id) | webサーバーフロントALBにアタッチするセキュリティグループのID |
| <a name="output_certificate_authority"></a> [certificate\_authority](#output\_certificate\_authority) | EKS CA |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS Cluster 名 |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | EKS API Endpoint |
<!-- END_TF_DOCS -->
