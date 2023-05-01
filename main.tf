# Create S3 bucket
module "s3_pipeline_bucket" {
  source  = "snowplow-devops/s3-bucket/aws"
  version = "0.2.0"

  bucket_name = var.s3_bucket_name

  tags = var.tags
}

# Setup key for SSH into deployed servers
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pipeline" {
  key_name   = "snowplow-pipeline"
  public_key = tls_private_key.tls_key.public_key_openssh
}

# Deploy Kinesis streams
module "raw_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-raw-stream"

  tags = var.tags
}

module "bad_1_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-bad-1-stream"
  tags = var.tags
}

module "enriched_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-enriched-stream"

  tags = var.tags
}

module "bad_2_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.3.0"

  name = "snowplow-bad-2-stream"

  tags = var.tags
}

# Deploy Collector stack
module "collector_lb" {
  source  = "snowplow-devops/alb/aws"
  version = "0.2.0"

  name              = "snowplow-collector-lb"
  vpc_id            = var.vpc_id
  subnet_ids        = var.public_subnet_ids
  health_check_path = "/health"

  ssl_certificate_arn     = var.ssl_information.certificate_arn
  ssl_certificate_enabled = var.ssl_information.enabled

  tags = var.tags
}

module "collector_kinesis" {
  source  = "snowplow-devops/collector-kinesis-ec2/aws"
  version = "0.5.1"

  name       = "snowplow-collector-server"
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  collector_lb_sg_id = module.collector_lb.sg_id
  collector_lb_tg_id = module.collector_lb.tg_id
  ingress_port       = module.collector_lb.tg_egress_port
  good_stream_name   = module.raw_stream.name
  bad_stream_name    = module.bad_1_stream.name

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  tags = var.tags
}

# Deploy Enrichment
module "enrich_kinesis" {
  source  = "snowplow-devops/enrich-kinesis-ec2/aws"
  version = "0.5.1"

  name                 = "snowplow-enrich-server"
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids
  in_stream_name       = module.raw_stream.name
  enriched_stream_name = module.enriched_stream.name
  bad_stream_name      = module.bad_1_stream.name

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  # Linking in the custom Iglu Server here
  custom_iglu_resolvers = local.custom_iglu_resolvers

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

resource "aws_sqs_queue" "message_queue" {
  content_based_deduplication = true
  name                        = "snowplow-loader.fifo"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
}

# Save raw, enriched and bad data to Amazon S3
module "s3_loader_raw" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.4.1"

  name             = "snowplow-s3-loader-raw-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.raw_stream.name
  bad_stream_name  = module.bad_1_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "raw/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

module "s3_loader_bad" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.4.1"

  name             = "snowplow-s3-loader-bad-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.bad_1_stream.name
  bad_stream_name  = module.bad_2_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "bad/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

module "s3_loader_enriched" {
  source  = "snowplow-devops/s3-loader-kinesis-ec2/aws"
  version = "0.4.1"

  name             = "snowplow-s3-loader-enriched-server"
  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnet_ids
  in_stream_name   = module.enriched_stream.name
  bad_stream_name  = module.bad_1_stream.name
  s3_bucket_name   = module.s3_pipeline_bucket.id
  s3_object_prefix = "enriched/"

  ssh_key_name                = aws_key_pair.pipeline.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_permissions_boundary    = var.iam_permissions_boundary

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  tags = var.tags
}

# Save events to ElasticSearch
module "elasticsearch-loader-good" {
  source  = "snowplow-devops/elasticsearch-loader-kinesis-ec2/aws"
  version = "0.4.1"

  name         = "snowplow-es-loader-enriched-server"
  vpc_id       = var.vpc_id
  subnet_ids   = var.public_subnet_ids
  ssh_key_name = aws_key_pair.pipeline.key_name

  in_stream_type  = "ENRICHED_EVENTS"
  in_stream_name  = module.enriched_stream.name
  bad_stream_name = module.bad_1_stream.name

  es_cluster_endpoint         = var.es_cluster_endpoint
  es_cluster_port             = var.es_cluster_port
  es_cluster_http_ssl_enabled = var.es_cluster_http_ssl_enabled

  es_cluster_index         = var.es_cluster_index
  es_cluster_document_type = "good"

  es_cluster_username = var.es_cluster_username
  es_cluster_password = var.es_cluster_password
  aws_es_domain_name  = var.aws_es_domain_name
}

module "elasticsearch-loader-bad" {
  count   = var.es_cluster_index_bad == "" ? 0 : 1
  source  = "snowplow-devops/elasticsearch-loader-kinesis-ec2/aws"
  version = "0.4.1"

  name         = "snowplow-es-loader-bad-server"
  vpc_id       = var.vpc_id
  subnet_ids   = var.public_subnet_ids
  ssh_key_name = aws_key_pair.pipeline.key_name

  in_stream_type  = "BAD_ROWS"
  in_stream_name  = module.bad_1_stream.name
  bad_stream_name = module.bad_2_stream.name

  es_cluster_endpoint         = var.es_cluster_endpoint
  es_cluster_port             = var.es_cluster_port
  es_cluster_http_ssl_enabled = var.es_cluster_http_ssl_enabled

  es_cluster_index         = var.es_cluster_index_bad
  es_cluster_document_type = "bad"

  es_cluster_username = var.es_cluster_username
  es_cluster_password = var.es_cluster_password
  aws_es_domain_name  = var.aws_es_domain_name
}
