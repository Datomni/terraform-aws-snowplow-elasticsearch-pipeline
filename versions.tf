terraform {
  required_version = ">= 1.3.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.45.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }
}
