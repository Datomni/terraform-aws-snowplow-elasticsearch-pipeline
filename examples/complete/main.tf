terraform {
  required_version = ">= 1.3.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.4.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "snowplow-elasticsearch-pipeline" {
  source = "Datomni/snowplow-elasticsearch-pipeline/aws"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  s3_bucket_name = var.s3_bucket_name

  iglu_server_url    = var.iglu_server_url
  iglu_server_apikey = var.iglu_server_apikey

  es_cluster_endpoint         = var.es_cluster_endpoint
  es_cluster_index            = var.es_cluster_index
  es_cluster_port             = var.es_cluster_port
  es_cluster_http_ssl_enabled = var.es_cluster_http_ssl_enabled
  aws_es_domain_name          = var.aws_es_domain_name
}
