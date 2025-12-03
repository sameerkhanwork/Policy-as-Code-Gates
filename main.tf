provider "aws" {
  region = "us-east-1"
}
 
# VIOLATION 1: Checkov will fail this (Public Bucket)
resource "aws_s3_bucket" "bad_bucket" {
  bucket = "my-dangerous-bucket-12345"
  acl    = "public-read" 
}
 
# VIOLATION 2: Conftest will fail this (Missing IRSA annotation)
resource "kubernetes_service_account" "bad_sa" {
  metadata {
    name = "bad-service-account"
    # Missing annotations = { "eks.amazonaws.com/role-arn" = ... }
  }
}
 
# VIOLATION 3: Conftest will fail this (Hardcoded Keys)
resource "kubernetes_deployment" "bad_deploy" {
  metadata {
    name = "bad-app"
  }
  spec {
    selector {
      match_labels = {
        app = "bad-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "bad-app"
        }
      }
      spec {
        container {
          name  = "app"
          image = "nginx"
          env {
            name  = "AWS_ACCESS_KEY_ID"
            value = "AKIAIOSFODNN7EXAMPLE" 
          }
        }
      }
    }
  }
}
 


# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "6.24.0"
#     }
#   }
# }

# provider "aws" {
#   # Configuration options
#   region = "us-east-1"
# }
# # MISTAKE 1: Public S3 Bucket (Security Risk)
# resource "aws_s3_bucket" "bad_bucket" {
#   bucket = "my-dangerous-bucket"
#   acl = "public-read"
# }

# # MISTAKE 2: Missing Encryption (KMS) and Tags
# resource "aws_ebs_volume" "example" {
#   availability_zone = "us-east-1a"
#   size = 40
#   # No encrypted = true
#   # No tags defined
# }