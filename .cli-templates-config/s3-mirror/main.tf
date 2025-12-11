terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  type = string
}

variable "github_iam_user_name" {
  type    = string
  default = "github-actions-cli-templates"
}

########################
# S3 Bucket (private, encrypted)
########################

resource "aws_s3_bucket" "repo_mirror" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "repo_mirror" {
  bucket = aws_s3_bucket.repo_mirror.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "repo_mirror" {
  bucket = aws_s3_bucket.repo_mirror.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "repo_mirror" {
  bucket = aws_s3_bucket.repo_mirror.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "repo_mirror" {
  depends_on = [
    aws_s3_bucket_ownership_controls.repo_mirror,
    aws_s3_bucket_public_access_block.repo_mirror
  ]

  bucket = aws_s3_bucket.repo_mirror.id
  acl    = "private"
}

########################
# IAM user for GitHub Actions
########################

resource "aws_iam_user" "github_actions" {
  name = var.github_iam_user_name
}

resource "aws_iam_user_policy" "github_s3_policy" {
  user = aws_iam_user.github_actions.name
  name = "github-actions-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.repo_mirror.arn,
        "${aws_s3_bucket.repo_mirror.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

########################
# CloudFront OAC for S3 origin
########################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "repo-mirror-oac"
  description                       = "OAC for private S3 repo mirror"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################
# CloudFront distribution in front of private S3
########################

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for private S3 repo mirror"

  origin {
    domain_name              = aws_s3_bucket.repo_mirror.bucket_regional_domain_name
    origin_id                = "s3-repo-mirror-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-repo-mirror-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

########################
# Bucket policy: allow only CloudFront (OAC)
########################

resource "aws_s3_bucket_policy" "repo_mirror_cf_access" {
  bucket = aws_s3_bucket.repo_mirror.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudFrontServicePrincipalReadOnly"
        Effect   = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.repo_mirror.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

########################
# Outputs
########################

output "cdn_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "aws_access_key_id" {
  value = aws_iam_access_key.github_actions.id
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}

output "s3_bucket_name" {
  value = aws_s3_bucket.repo_mirror.bucket
}
