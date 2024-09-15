#############
# Provider情報
#############
terraform {
  required_version = ">= 1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Environment = var.env
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.endpoint
    cluster_ca_certificate = base64decode(module.eks.certificate_authority)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

#############
# Backend情報
#############
terraform {
  # 複数名と共同開発する場合は 「backend "s3" {...}」のコメントアウトを解除し、
  #「backend "local" {}」をコメントアウトしてください。
  backend "local" {}
  # backend "s3" {
  #   region = "ap-northeast-1"
  #   bucket = "<tfstate管理S3バケット名>"
  #   key    = "terraform.tfstate"
  # }
}