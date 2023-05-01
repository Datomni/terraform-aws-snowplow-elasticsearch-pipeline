# terraform-aws-snowplow-elasticsearch-pipeline
## Overview
A Terraform module which deploys a pipeline to load Snowplow data into ElasticSearch using the [Snowplow Open Source](https://docs.snowplow.io/docs/getting-started-on-snowplow-open-source/what-is-snowplow-open-source/) artefacts.

This module builds the Collector application, the Enrich application and the ElasticSearch Loader.

For more details on the Snowplow Pipeline, please visit their Official Documentation site:

https://docs.snowplow.io/docs/understanding-your-pipeline/architecture-overview-aws/


ElasticSearch loader specific details and pre-requisites are documented here:

https://docs.snowplow.io/docs/destinations/forwarding-events/elasticsearch/#setup-guide

## Usage
Import the module and provide the required configuration variables. 
```
module "snowplow-databricks-pipeline" {
  source = "Datomni/snowplow-elasticsearch-pipeline/aws"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  s3_bucket_name = var.s3_bucket_name
  
  iglu_server_url      = var.iglu_server_url
  iglu_server_apikey   = var.iglu_server_apikey

  es_cluster_endpoint         = var.es_cluster_endpoint
  es_cluster_index            = var.es_cluster_index
  es_cluster_port             = var.es_cluster_port
  es_cluster_http_ssl_enabled = var.es_cluster_http_ssl_enabled
  aws_es_domain_name          = var.aws_es_domain_name
}
```


## Examples
For a complete example, see [examples/complete](https://github.com/Datomni/terraform-aws-snowplow-elasticsearch-pipeline/tree/main/examples/complete)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version    |
|------|------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | \>= 1.3.1  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | \>= 3.45.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | \>= 4.0.4  |

## Providers

| Name | Version    |
|------|------------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>= 3.45.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | \>= 4.0.4  |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bad_1_stream"></a> [bad\_1\_stream](#module\_bad\_1\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_bad_2_stream"></a> [bad\_2\_stream](#module\_bad\_2\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_collector_kinesis"></a> [collector\_kinesis](#module\_collector\_kinesis) | snowplow-devops/collector-kinesis-ec2/aws | 0.5.1 |
| <a name="module_collector_lb"></a> [collector\_lb](#module\_collector\_lb) | snowplow-devops/alb/aws | 0.2.0 |
| <a name="module_elasticsearch-loader-bad"></a> [elasticsearch-loader-bad](#module\_elasticsearch-loader-bad) | snowplow-devops/elasticsearch-loader-kinesis-ec2/aws | 0.4.1 |
| <a name="module_elasticsearch-loader-good"></a> [elasticsearch-loader-good](#module\_elasticsearch-loader-good) | snowplow-devops/elasticsearch-loader-kinesis-ec2/aws | 0.4.1 |
| <a name="module_enrich_kinesis"></a> [enrich\_kinesis](#module\_enrich\_kinesis) | snowplow-devops/enrich-kinesis-ec2/aws | 0.5.1 |
| <a name="module_enriched_stream"></a> [enriched\_stream](#module\_enriched\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_raw_stream"></a> [raw\_stream](#module\_raw\_stream) | snowplow-devops/kinesis-stream/aws | 0.3.0 |
| <a name="module_s3_loader_bad"></a> [s3\_loader\_bad](#module\_s3\_loader\_bad) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.4.1 |
| <a name="module_s3_loader_enriched"></a> [s3\_loader\_enriched](#module\_s3\_loader\_enriched) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.4.1 |
| <a name="module_s3_loader_raw"></a> [s3\_loader\_raw](#module\_s3\_loader\_raw) | snowplow-devops/s3-loader-kinesis-ec2/aws | 0.4.1 |
| <a name="module_s3_pipeline_bucket"></a> [s3\_pipeline\_bucket](#module\_s3\_pipeline\_bucket) | snowplow-devops/s3-bucket/aws | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_sqs_queue.message_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [tls_private_key.tls_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to the resource. Required if resources are created in a public subnet | `bool` | `true` | no |
| <a name="input_aws_es_domain_name"></a> [aws\_es\_domain\_name](#input\_aws\_es\_domain\_name) | AWS Opensearch/Elasticsearch domain name. Set if you want to use AWS Request Signing to authenticate. Note: This requires configuring either an IAM cluster policy and/or fine-grained-access-control with the IAM role created by the ES Loader modules | `string` | `""` | no |
| <a name="input_es_cluster_endpoint"></a> [es\_cluster\_endpoint](#input\_es\_cluster\_endpoint) | Elasticsearch cluster endpoint | `string` | n/a | yes |
| <a name="input_es_cluster_http_ssl_enabled"></a> [es\_cluster\_http\_ssl\_enabled](#input\_es\_cluster\_http\_ssl\_enabled) | Elasticsearch cluster SSL enabled flag - If set to enabled connection type is https, otherwise connection type is http | `bool` | `true` | no |
| <a name="input_es_cluster_index"></a> [es\_cluster\_index](#input\_es\_cluster\_index) | Elasticsearch cluster index - Good stream | `string` | n/a | yes |
| <a name="input_es_cluster_index_bad"></a> [es\_cluster\_index\_bad](#input\_es\_cluster\_index\_bad) | Elasticsearch cluster index - Bad stream. Set if you want to load bad records to ElasticSearch | `string` | `""` | no |
| <a name="input_es_cluster_password"></a> [es\_cluster\_password](#input\_es\_cluster\_password) | Elasticsearch cluster password. Set if you want to use basicauth to authenticate. Note: If using RBAC with AWS ES this should not be set as the authentication is done via the IAM role attached to the loader instances instead | `string` | `""` | no |
| <a name="input_es_cluster_port"></a> [es\_cluster\_port](#input\_es\_cluster\_port) | Elasticsearch cluster port | `number` | n/a | yes |
| <a name="input_es_cluster_username"></a> [es\_cluster\_username](#input\_es\_cluster\_username) | Elasticsearch cluster user. Set if you want to use basicauth to authenticate. Note: If using RBAC with AWS ES this should not be set as the authentication is done via the IAM role attached to the loader instances instead | `string` | `""` | no |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | The permissions boundary ARN to set on IAM roles created | `string` | `""` | no |
| <a name="input_iglu_server_apikey"></a> [iglu\_server\_apikey](#input\_iglu\_server\_apikey) | Iglu Server API key | `string` | n/a | yes |
| <a name="input_iglu_server_url"></a> [iglu\_server\_url](#input\_iglu\_server\_url) | Iglu Server url/dns | `string` | n/a | yes |
| <a name="input_pipeline_kcl_write_max_capacity"></a> [pipeline\_kcl\_write\_max\_capacity](#input\_pipeline\_kcl\_write\_max\_capacity) | Increasing this is important to increase throughput at very high pipeline volumes | `number` | `10` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The list of private subnets to deploy resources across | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The list of public subnets to deploy resources across | `list(string)` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket with transformed snowplow events | `string` | n/a | yes |
| <a name="input_ssl_information"></a> [ssl\_information](#input\_ssl\_information) | The ARN of an Amazon Certificate Manager certificate to bind to the load balancer | <pre>object({<br>    enabled         = bool<br>    certificate_arn = string<br>  })</pre> | <pre>{<br>  "certificate_arn": "",<br>  "enabled": false<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to the resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to deploy resources within | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collector_dns_name"></a> [collector\_dns\_name](#output\_collector\_dns\_name) | The ALB dns name for the Pipeline Collector |
<!-- END_TF_DOCS -->