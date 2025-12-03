terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.24.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
# MISTAKE 1: Public S3 Bucket (Security Risk)
resource "aws_s3_bucket" "bad_bucket" {
  bucket = "my-dangerous-bucket"
  acl = "public-read"
}

# MISTAKE 2: Missing Encryption (KMS) and Tags
resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1a"
  size = 40
  # No encrypted = true
  # No tags defined
}