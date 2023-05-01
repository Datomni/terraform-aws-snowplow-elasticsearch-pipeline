variable "vpc_id" {
  description = "The VPC to deploy resources within"
  type        = string
}

variable "private_subnet_ids" {
  description = "The list of private subnets to deploy resources across"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The list of public subnets to deploy resources across"
  type        = list(string)
}

variable "s3_bucket_name" {
  description = "S3 bucket with transformed snowplow events"
  type        = string
}

variable "iglu_server_url" {
  description = "Iglu Server url/dns"
  type        = string
}

variable "iglu_server_apikey" {
  description = "Iglu Server API key"
  type        = string
}

variable "es_cluster_endpoint" {
  description = "Elasticsearch cluster endpoint"
  type        = string
}

variable "es_cluster_index" {
  description = "Elasticsearch cluster index"
  type        = string
}

variable "es_cluster_port" {
  description = "Elasticsearch cluster port"
  type        = number
}

variable "es_cluster_http_ssl_enabled" {
  description = "Elasticsearch cluster SSL enabled flag"
  type        = bool
}

variable "aws_es_domain_name" {
  description = "AWS Opensearch/Elasticsearch domain name"
  type        = string
}
