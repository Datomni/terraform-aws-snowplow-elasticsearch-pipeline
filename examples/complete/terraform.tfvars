# --- VPC Configuration
vpc_id             = "vpc-12345"
private_subnet_ids = ["subnet-123", "subnet-345", ]
public_subnet_ids  = ["subnet-678", "subnet-901", ]

# --- S3 Configuration
s3_bucket_name = "snowplow-data-bucket"

# --- Iglu Server Configuration
iglu_server_url    = "http://sp-iglu-lb-1234567.us-east-1.elb.amazonaws.com"
iglu_server_apikey = "ABCD-1234-4567-9011-EFG"

# --- ElasticSearch Cluster Configuration
es_cluster_endpoint         = "search-elasticsearch-cluster-abc123.us-east-1.es.amazonaws.com"
es_cluster_index            = "snowplow-enriched-index"
es_cluster_port             = 443
es_cluster_http_ssl_enabled = true
aws_es_domain_name          = "elasticsearch-cluster"
