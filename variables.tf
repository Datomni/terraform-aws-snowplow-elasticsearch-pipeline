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

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to the resource. Required if resources are created in a public subnet"
  type        = bool
  default     = true
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  type        = string
  default     = ""
}

variable "ssl_information" {
  description = "The ARN of an Amazon Certificate Manager certificate to bind to the load balancer"
  type = object({
    enabled         = bool
    certificate_arn = string
  })
  default = {
    certificate_arn = ""
    enabled         = false
  }
}

variable "pipeline_kcl_write_max_capacity" {
  description = "Increasing this is important to increase throughput at very high pipeline volumes"
  type        = number
  default     = 10
}

variable "tags" {
  description = "The tags to append to the resources"
  type        = map(string)
  default     = {}
}

variable "es_cluster_endpoint" {
  description = "Elasticsearch cluster endpoint"
  type        = string
}

variable "es_cluster_index" {
  description = "Elasticsearch cluster index - Good stream"
  type        = string
}

variable "es_cluster_index_bad" {
  description = "Elasticsearch cluster index - Bad stream. Set if you want to load bad records to ElasticSearch"
  type        = string
  default     = ""
}

variable "es_cluster_port" {
  description = "Elasticsearch cluster port"
  type        = number
}

variable "es_cluster_username" {
  description = "Elasticsearch cluster user. Set if you want to use basicauth to authenticate. Note: If using RBAC with AWS ES this should not be set as the authentication is done via the IAM role attached to the loader instances instead"
  type        = string
  default     = ""
}

variable "es_cluster_password" {
  description = "Elasticsearch cluster password. Set if you want to use basicauth to authenticate. Note: If using RBAC with AWS ES this should not be set as the authentication is done via the IAM role attached to the loader instances instead"
  type        = string
  default     = ""
}

variable "es_cluster_http_ssl_enabled" {
  description = "Elasticsearch cluster SSL enabled flag - If set to enabled connection type is https, otherwise connection type is http"
  type        = bool
  default     = true
}

variable "aws_es_domain_name" {
  description = "AWS Opensearch/Elasticsearch domain name. Set if you want to use AWS Request Signing to authenticate. Note: This requires configuring either an IAM cluster policy and/or fine-grained-access-control with the IAM role created by the ES Loader modules"
  type        = string
  default     = ""
}
