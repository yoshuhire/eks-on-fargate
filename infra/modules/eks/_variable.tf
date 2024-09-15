#############
# 環境区分
#############
variable "env" {
  description = "本開区分の指定(prd or dev)"
  type        = string

  validation {
    condition     = contains(["dev", "prd"], var.env)
    error_message = "env must be either dev or prd"
  }
}

#############
# リージョン
#############
variable "region" {
  description = "リージョン"
  type        = string
  default     = "ap-northeast-1"
}

#############
# VPC 設定
#############
variable "vpc_config" {
  description = "VPC設定"
  type = object({
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
  })
  default = {
    cidr_block           = "192.168.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

#############
# サブネット設定
#############
variable "subnet_config" {
  type = map(list(object({
    availability_zone = string
    cidr_block        = string
  })))
  description = "サブネット設定"
  default = {
    "private" = [
      {
        availability_zone = "ap-northeast-1a"
        cidr_block        = "192.168.0.0/24"
      },
      {
        availability_zone = "ap-northeast-1c"
        cidr_block        = "192.168.1.0/24"
      },
      {
        availability_zone = "ap-northeast-1d"
        cidr_block        = "192.168.2.0/24"
      }
    ],
    "public" = [
      {
        availability_zone = "ap-northeast-1a"
        cidr_block        = "192.168.3.0/24"
      },
      {
        availability_zone = "ap-northeast-1c"
        cidr_block        = "192.168.4.0/24"
      },
      {
        availability_zone = "ap-northeast-1d"
        cidr_block        = "192.168.5.0/24"
      }
    ]
  }

  validation {
    condition     = alltrue([for key in keys(var.subnet_config) : contains(["private", "public"], key)])
    error_message = "subnet_config keys must be either 'private' or 'public'"
  }
}

#############
# VPCE
#############
variable "vpce_config" {
  type = list(object({
    usage             = string
    service_name      = string
    vpc_endpoint_type = string
  }))
  description = "VPCE設定リスト"
  default = [
    {
      usage             = "s3"
      service_name      = "com.amazonaws.ap-northeast-1.s3"
      vpc_endpoint_type = "Gateway"
    },
    {
      usage             = "ecr.api"
      service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
      vpc_endpoint_type = "Interface"
    },
    {
      usage             = "ecr.dkr"
      service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
      vpc_endpoint_type = "Interface"
    },
    {
      usage             = "sts"
      service_name      = "com.amazonaws.ap-northeast-1.sts"
      vpc_endpoint_type = "Interface"
    },
    {
      usage             = "ec2"
      service_name      = "com.amazonaws.ap-northeast-1.ec2"
      vpc_endpoint_type = "Interface"
    },
    {
      usage             = "elasticloadbalancing"
      service_name      = "com.amazonaws.ap-northeast-1.elasticloadbalancing"
      vpc_endpoint_type = "Interface"
    }
  ]
}

#############
# ECR リポジトリリスト 
#############
variable "ecr_repo_list" {
  description = "ECR リポジトリリスト"
  type        = list(string)
  default = [
    "ecr-public/eks/aws-load-balancer-controller",
    "web-server",
    "k8s/metrics-server/metrics-server",
    "k8s/autoscaling/addon-resizer"
  ]
}

#############
# EKS cluster 設定 
#############
variable "cluster_config" {
  description = "EKS クラスター設定"
  type = object({
    version                 = string
    enabled_log_types       = list(string)
    endpoint_private_access = bool
    endpoint_public_access  = bool
    addons              = any
    aws_auth_roles = list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    }))
  })
  default = {
    version                 = "1.29"
    enabled_log_types       = ["audit", "api", "authenticator"]
    endpoint_private_access = true
    endpoint_public_access  = true
    addons = {
      coredns = {
        most_recent = true
        configuration_values = {
          "computeType" = "Fargate"
        }
      }
      vpc-cni = {
        most_recent = true
      }
    }
    aws_auth_roles = []
  }
}

variable "fargate_profile_config" {
  description = "Fargateプロファイル設定"
  type = any
  default =  {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
    }
    web-server = {
      selectors = [
        {
          namespace = "web-server"
        }
      ]
    }
  }
}

#############
# アクセス許可IPリスト 
#############
variable "accessible_ip_list" {
  description = "アクセス許可IPリスト"
  type = object({
    to_web_server      = list(string)
    to_kube_api_server = list(string)
  })
}